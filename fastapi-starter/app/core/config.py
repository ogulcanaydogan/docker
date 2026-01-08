"""Application configuration."""

from functools import lru_cache

from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    """Application settings loaded from environment variables."""

    # App settings
    APP_NAME: str = "FastAPI Starter"
    APP_DESCRIPTION: str = "A production-ready FastAPI template"
    APP_VERSION: str = "1.0.0"
    DEBUG: bool = False
    ENVIRONMENT: str = "production"

    # Server settings
    HOST: str = "0.0.0.0"
    PORT: int = 8000
    WORKERS: int = 1

    # Security
    SECRET_KEY: str = "change-me-in-production"
    API_KEY: str | None = None
    SHOW_DOCS: bool = True

    # CORS
    CORS_ORIGINS: list[str] = ["*"]

    # Database (optional)
    DATABASE_URL: str | None = None

    # Redis (optional)
    REDIS_URL: str | None = None

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"
        case_sensitive = True


@lru_cache
def get_settings() -> Settings:
    """Get cached settings instance."""
    return Settings()


settings = get_settings()
