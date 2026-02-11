"""Hello world API endpoints."""

from fastapi import APIRouter
from pydantic import BaseModel

router = APIRouter()


class HelloResponse(BaseModel):
    """Response model for hello endpoint."""

    message: str


@router.get("/hello", response_model=HelloResponse)
async def get_hello() -> HelloResponse:
    """
    Return a hello world message.

    Returns:
        HelloResponse: A greeting message
    """
    return HelloResponse(message="Hello, World!")


@router.get("/hello/{name}", response_model=HelloResponse)
async def get_hello_name(name: str) -> HelloResponse:
    """
    Return a personalized greeting.

    Args:
        name: Name to greet

    Returns:
        HelloResponse: A personalized greeting message
    """
    return HelloResponse(message=f"Hello, {name}!")
