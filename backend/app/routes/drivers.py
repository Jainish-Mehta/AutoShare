from fastapi import APIRouter, HTTPException, WebSocket, WebSocketDisconnect
from app.models.ride import DriverLocationUpdate, DriverStatusUpdate, NearbyAuto
from app.database import supabase
from typing import List
from app.websockets.location import manager
import json

router = APIRouter()

# ── Get Driver Stats ───────────────────────────────────────────────────────
# Returns driver's rating, total trips and earnings
# Called when driver opens the home page

@router.get("/stats/{driver_id}")
def get_driver_stats(driver_id: str):
    result = supabase.table("drivers").select(
        "rating, total_trips, total_earnings"
    ).eq("id", driver_id).execute()

    if not result.data:
        raise HTTPException(status_code=404, detail="Driver not found")

    return result.data[0]

# ── Driver Goes Online/Offline ─────────────────────────────────────────────
# When driver taps "Go Online", we mark them as available in the database
# When they go offline, we mark them unavailable so customers can't see them

@router.post("/status")
def update_driver_status(data: DriverStatusUpdate):
    result = supabase.table("drivers").update({
        "is_online": data.is_online
    }).eq("id", data.driver_id).execute()

    if not result.data:
        raise HTTPException(status_code=404, detail="Driver not found")

    status = "online" if data.is_online else "offline"
    return {"message": f"Driver is now {status}"}

# ── Update Driver Location ─────────────────────────────────────────────────
# Driver app calls this every few seconds with their current GPS coordinates
# We store it as a PostGIS POINT in the database
# This is what lets customers see nearby autos in real time

@router.post("/location")
def update_driver_location(data: DriverLocationUpdate):
    # PostGIS expects coordinates as POINT(longitude latitude)
    # Note: longitude comes FIRST in PostGIS
    point = f"POINT({data.longitude} {data.latitude})"

    result = supabase.table("drivers").update({
        "current_location": point,
        "is_online": True
    }).eq("id", data.driver_id).execute()

    if not result.data:
        raise HTTPException(status_code=404, detail="Driver not found")

    return {"message": "Location updated"}

# ── Get Nearby Online Drivers ──────────────────────────────────────────────
# Customer calls this with their location
# We use PostGIS ST_DWithin to find all online drivers within 5km
# Results are sorted by distance — closest driver first

@router.get("/nearby", response_model=List[NearbyAuto])
def get_nearby_drivers(latitude: float, longitude: float, radius_meters: float = 5000):
    # ST_DWithin finds all points within X meters of a given point
    # ST_Distance calculates exact distance for sorting
    result = supabase.rpc("get_nearby_drivers", {
        "user_lat": latitude,
        "user_lng": longitude,
        "radius_m": radius_meters
    }).execute()

    if not result.data:
        return []

    return result.data

# ── Driver WebSocket ───────────────────────────────────────────────────────
# Driver app connects here when they go online
# Sends GPS coordinates every 3 seconds like:
# {"latitude": 23.0393, "longitude": 72.5129, "ride_id": "uuid-or-null"}
# We update database AND forward location to customer if ride is active

@router.websocket("/ws/driver/{driver_id}")
async def driver_websocket(websocket: WebSocket, driver_id: str):
    await manager.connect_driver(driver_id, websocket)

    supabase.table("drivers").update({
        "is_online": True
    }).eq("id", driver_id).execute()

    try:
        while True:
            data = await websocket.receive_text()
            location = json.loads(data)

            lat = location.get("latitude")
            lng = location.get("longitude")

            if lat and lng:
                print(f"Updating location: lat={lat}, lng={lng}")

                # Use RPC to update PostGIS location
                supabase.rpc("update_driver_location", {
                    "driver_id_input": driver_id,
                    "lat": lat,
                    "lng": lng
                }).execute()

                print(f"Location updated successfully")

    except WebSocketDisconnect:
        manager.disconnect_driver(driver_id)
        supabase.table("drivers").update({
            "is_online": False
        }).eq("id", driver_id).execute()

# ── Get Driver Current Location ────────────────────────────────────────────
# Called by customer app every 3 seconds to get latest driver position
# PostGIS stores location as binary — we extract lat/lng using ST_X/ST_Y
# Returns simple lat/lng that Flutter can use directly

@router.get("/location/{driver_id}")
def get_driver_location(driver_id: str):
    result = supabase.rpc("get_driver_location", {
        "driver_id_input": driver_id
    }).execute()

    # RPC returning a single JSON object comes back differently
    # result.data is the JSON directly, not a list
    if not result.data:
        raise HTTPException(status_code=404, detail="Driver location not found")

    # Handle both cases — list or direct dict
    data = result.data
    if isinstance(data, list):
        if len(data) == 0:
            raise HTTPException(status_code=404, detail="Driver location not found")
        return data[0]
    else:
        return data