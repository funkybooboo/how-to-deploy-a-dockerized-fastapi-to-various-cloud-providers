"""
FastAPI application entry point.

This module initializes the FastAPI application with proper configuration,
middleware, and routing.
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from .api import health, hello
from .config import get_settings

# Load configuration from environment
settings = get_settings()

# Conditional debug mode for development
# SECURITY: Only enable debugpy when DEBUG environment variable is true
if settings.DEBUG:
    import debugpy

    debugpy.listen(("0.0.0.0", 5678))
    print(f"🐛 Debugger listening on port 5678 (DEBUG={settings.DEBUG})")

# Initialize FastAPI application
app = FastAPI(
    title="FastAPI Cloud Deployment",
    description="Production-ready FastAPI application for multi-cloud deployment",
    version=settings.API_VERSION,
    docs_url=f"{settings.API_PREFIX}/docs",
    redoc_url=f"{settings.API_PREFIX}/redoc",
)

# Configure CORS middleware
# SECURITY: CORS origins are configurable via environment variable
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include API routers
app.include_router(health.router, prefix=settings.API_PREFIX, tags=["health"])
app.include_router(hello.router, prefix=settings.API_PREFIX, tags=["hello"])


@app.get("/")
async def root():
    """
    Root endpoint for basic health check.

    Returns:
        dict: Simple health status message with environment info
    """
    return {
        "message": "OK 🚀",
        "version": settings.API_VERSION,
        "environment": settings.ENVIRONMENT,
    }


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(
        app,
        host=settings.HOST,
        port=settings.PORT,
        log_level=settings.LOG_LEVEL.lower(),
    )
