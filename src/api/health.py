"""Health check API endpoints."""

from fastapi import APIRouter
from pydantic import BaseModel

router = APIRouter()


class HealthResponse(BaseModel):
    """Response model for health check endpoint."""

    status: str
    message: str


@router.get("/health", response_model=HealthResponse)
async def get_health() -> HealthResponse:
    """
    Health check endpoint.

    Returns:
        HealthResponse: Health status of the application
    """
    return HealthResponse(status="healthy", message="OK")
