from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    SUPABASE_URL: str
    SUPABASE_KEY: str
    SECRET_KEY: str
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60
    RAZORPAY_KEY_ID: str
    RAZORPAY_KEY_SECRET: str

    class Config:
        env_file = ".env"

settings = Settings()