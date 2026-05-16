from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.routes import auth, rides, drivers, payments

app = FastAPI(
    title="AutoShare API",
    description="Backend for AutoShare auto rickshaw booking app",
    version="1.0.0"
)

# CORS — allows Flutter app to talk to this backend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Routes
app.include_router(auth.router,     prefix="/auth",     tags=["Auth"])
app.include_router(rides.router,    prefix="/rides",    tags=["Rides"])
app.include_router(drivers.router,  prefix="/drivers",  tags=["Drivers"])
app.include_router(payments.router, prefix="/payments", tags=["Payments"])

@app.get("/")
def root():
    return {"message": "AutoShare API is running 🚀"}