import razorpay
from app.config import settings

# Initialize Razorpay client with your key and secret
# This client is used to create orders and verify payments
client = razorpay.Client(
    auth=(settings.RAZORPAY_KEY_ID, settings.RAZORPAY_KEY_SECRET)
)

# ── Create Order ───────────────────────────────────────────────────────────
# Before showing payment sheet, we create an order on Razorpay server
# Amount must be in paise (1 rupee = 100 paise)
# Returns order_id which Flutter uses to open payment sheet
def create_order(amount_rupees: float, ride_id: str) -> dict:
    amount_paise = int(amount_rupees * 100)
    order = client.order.create({
        "amount": amount_paise,
        "currency": "INR",
        "receipt": ride_id,        # links order to your ride
        "notes": {
            "ride_id": ride_id     # extra info stored with order
        }
    })
    return order

# ── Verify Payment ─────────────────────────────────────────────────────────
# After customer pays, Razorpay gives 3 IDs
# We verify these match using HMAC signature
# This confirms payment is genuine and not tampered with
def verify_payment(
    razorpay_order_id: str,
    razorpay_payment_id: str,
    razorpay_signature: str
) -> bool:
    try:
        client.utility.verify_payment_signature({
            "razorpay_order_id": razorpay_order_id,
            "razorpay_payment_id": razorpay_payment_id,
            "razorpay_signature": razorpay_signature
        })
        return True
    except Exception:
        return False