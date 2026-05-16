from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from app.services.razorpay import create_order, verify_payment
from app.database import supabase
from app.config import settings

router = APIRouter()

# ── Request/Response Models ────────────────────────────────────────────────

# Customer sends ride_id and fare to create a payment order
class CreateOrderRequest(BaseModel):
    ride_id: str
    amount: float  # in rupees

# After payment, Flutter sends these 3 IDs for verification
class VerifyPaymentRequest(BaseModel):
    ride_id: str
    razorpay_order_id: str
    razorpay_payment_id: str
    razorpay_signature: str

# ── Create Razorpay Order ──────────────────────────────────────────────────
# Called when customer taps "Pay" button
# Creates an order on Razorpay and returns order_id + key_id
# Flutter needs both to open the payment sheet

@router.post("/create-order")
def create_payment_order(data: CreateOrderRequest):
    try:
        # Create order on Razorpay
        order = create_order(data.amount, data.ride_id)

        # Save order in our database
        supabase.table("payments").insert({
            "ride_id": data.ride_id,
            "amount": data.amount,
            "method": "razorpay",
            "razorpay_order_id": order["id"],
            "status": "pending"
        }).execute()

        # Return order details to Flutter
        # Flutter needs order_id and key_id to open payment sheet
        return {
            "order_id": order["id"],
            "amount": order["amount"],      # in paise
            "currency": order["currency"],
            "key_id": settings.RAZORPAY_KEY_ID  # needed by Flutter SDK
        }

    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Failed to create payment order: {str(e)}"
        )

# ── Verify Payment ─────────────────────────────────────────────────────────
# Called after customer completes payment
# Verifies payment signature to confirm it's genuine
# Updates ride status to "completed" and payment status to "paid"

@router.post("/verify")
def verify_payment_endpoint(data: VerifyPaymentRequest):
    # Verify signature — confirms payment is genuine
    is_valid = verify_payment(
        data.razorpay_order_id,
        data.razorpay_payment_id,
        data.razorpay_signature
    )

    if not is_valid:
        raise HTTPException(
            status_code=400,
            detail="Invalid payment signature — payment may be tampered"
        )

    # Update payment record to paid
    supabase.table("payments").update({
        "razorpay_payment_id": data.razorpay_payment_id,
        "status": "paid"
    }).eq("razorpay_order_id", data.razorpay_order_id).execute()

    # Update ride status to completed
    supabase.table("rides").update({
        "status": "completed",
        "payment_status": "paid",
        "payment_method": "razorpay"
    }).eq("id", data.ride_id).execute()

    # Update driver earnings
    ride = supabase.table("rides").select(
        "fare, driver_id"
    ).eq("id", data.ride_id).execute()

    if ride.data:
        ride_data = ride.data[0] if isinstance(ride.data, list) else ride.data
        driver_id = ride_data["driver_id"]
        fare = ride_data["fare"]

        # Add fare to driver's total earnings and increment trip count
        supabase.rpc("update_driver_earnings", {
            "driver_id_input": driver_id,
            "fare_amount": fare
        }).execute()

    return {"message": "Payment verified successfully", "status": "paid"}

# ── Cash Payment ───────────────────────────────────────────────────────────
# When customer pays cash, no Razorpay involved
# Just mark ride as completed and payment as cash

@router.post("/cash")
def cash_payment(data: dict):
    ride_id = data.get("ride_id")
    if not ride_id:
        raise HTTPException(status_code=400, detail="ride_id required")

    # Get ride details
    ride = supabase.table("rides").select(
        "fare, driver_id"
    ).eq("id", ride_id).execute()

    if not ride.data:
        raise HTTPException(status_code=404, detail="Ride not found")

    ride_data = ride.data[0] if isinstance(ride.data, list) else ride.data

    # Update ride as completed with cash payment
    supabase.table("rides").update({
        "status": "completed",
        "payment_status": "paid",
        "payment_method": "cash"
    }).eq("id", ride_id).execute()

    # Update driver earnings
    supabase.rpc("update_driver_earnings", {
        "driver_id_input": ride_data["driver_id"],
        "fare_amount": ride_data["fare"]
    }).execute()

    return {"message": "Cash payment recorded", "status": "paid"}