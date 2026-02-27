from pydantic_settings import BaseSettings, SettingsConfigDict
from typing import Optional

class Settings(BaseSettings):
    # App Settings
    APP_NAME: str = "记否 API"
    DEBUG: bool = False
    
    # Database Settings
    DATABASE_URL: str = "sqlite:///./jifou.db"
    
    # AI Settings
    OPENAI_API_KEY: Optional[str] = None
    OPENAI_API_BASE: str = "https://api.openai.com/v1"
    AI_MODEL: str = "gpt-3.5-turbo"
    
    # OpenRouter Settings (Optional)
    OPENROUTER_API_KEY: Optional[str] = None
    OPENROUTER_BASE_URL: str = "https://openrouter.ai/api/v1"
    SITE_URL: str = "https://jifou.ai"
    SITE_NAME: str = "记否"
    
    # Security Settings
    SECRET_KEY: str = "your-secret-key-for-jwt-change-it-in-production"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 7  # 7 days
    
    model_config = SettingsConfigDict(env_file=".env")

settings = Settings()
