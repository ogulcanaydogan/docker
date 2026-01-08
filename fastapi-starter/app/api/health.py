"""Health check endpoints."""

from datetime import datetime

from fastapi import APIRouter

from app.core.config import settings

router = APIRouter()


@router.get("/health")
async def health_check():
    """Basic health check endpoint."""
    return {
        "status": "healthy",
        "timestamp": datetime.utcnow().isoformat(),
        "version": settings.APP_VERSION,
    }


@router.get("/health/ready")
async def readiness_check():
    """Readiness probe for Kubernetes."""
    # Add database/cache connectivity checks here
    checks = {
        "app": True,
    }

    if settings.DATABASE_URL:
        # TODO: Add actual database check
        checks["database"] = True

    if settings.REDIS_URL:
        # TODO: Add actual Redis check
        checks["redis"] = True

    all_healthy = all(checks.values())

    return {
        "status": "ready" if all_healthy else "not_ready",
        "checks": checks,
        "timestamp": datetime.utcnow().isoformat(),
    }


@router.get("/health/live")
async def liveness_check():
    """Liveness probe for Kubernetes."""
    return {"status": "alive"}
