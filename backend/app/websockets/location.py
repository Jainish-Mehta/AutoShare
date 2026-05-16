from fastapi import WebSocket
from typing import Dict
import json

# ── Connection Manager ─────────────────────────────────────────────────────
# Keeps track of all active WebSocket connections
# Two separate dictionaries:
#   - driver_connections: driver_id → WebSocket
#   - customer_connections: ride_id → list of WebSockets
# When driver sends location, we find the matching ride
# and forward location to the customer on that ride

class ConnectionManager:

    def __init__(self):
        # driver_id → WebSocket connection
        self.driver_connections: Dict[str, WebSocket] = {}

    # ── Connect driver ─────────────────────────────────────────────────
    # Called when driver opens the app and goes online
    async def connect_driver(self, driver_id: str, websocket: WebSocket):
        await websocket.accept()
        self.driver_connections[driver_id] = websocket
        print(f"Driver {driver_id} connected")

    # ── Disconnect ─────────────────────────────────────────────────────
    # Called when driver or customer closes the app
    def disconnect_driver(self, driver_id: str):
        self.driver_connections.pop(driver_id, None)
        print(f"Driver {driver_id} disconnected")

    # Keep this for ride status updates via FastAPI directly
    async def broadcast_to_driver(self, driver_id: str, message: dict):
        if driver_id in self.driver_connections:
            websocket = self.driver_connections[driver_id]
            try:
                await websocket.send_text(json.dumps(message))
            except Exception:
                self.disconnect_driver(driver_id)

# Single global instance used across the whole app
manager = ConnectionManager()