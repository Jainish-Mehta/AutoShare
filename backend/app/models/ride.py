from pydantic import BaseModel
from typing import Optional

# ── Driver Location ────────────────────────────────────────────────────────
# Sent by driver app every few seconds to update their position
class DriverLocationUpdate(BaseModel):
    driver_id: str
    latitude: float
    longitude: float

# ── Driver Online/Offline ──────────────────────────────────────────────────
# Driver sends this when they tap "Go Online" or "Go Offline"
class DriverStatusUpdate(BaseModel):
    driver_id: str
    is_online: bool

# ── Ride Request ───────────────────────────────────────────────────────────
# Customer sends this when they want to book a ride
class RideRequest(BaseModel):
    user_id: str
    driver_id: str
    pickup_latitude: float
    pickup_longitude: float
    dropoff_latitude: float
    dropoff_longitude: float
    pickup_address: Optional[str] = None
    dropoff_address: Optional[str] = None

# ── Ride Response ──────────────────────────────────────────────────────────
# What we send back after booking
class RideResponse(BaseModel):
    ride_id: str
    status: str
    fare: float
    distance_meters: float
    pickup_nearest_point: dict   # nearest point on fixed route to pickup
    dropoff_nearest_point: dict  # nearest point on fixed route to dropoff

# ── Nearby Auto ───────────────────────────────────────────────────────────
# Represents one auto in the nearby autos list
class NearbyAuto(BaseModel):
    driver_id: str
    name: str
    phone: str
    vehicle_number: str
    rating: float
    distance_meters: float
    latitude: float
    longitude: float