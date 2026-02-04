# Application Guide

Complete guide to understanding the FastAPI application structure, components, and how everything works together.

## Overview

This is a production-ready FastAPI application designed for multi-cloud deployment. It demonstrates best practices for:
- Clean code structure
- Environment-based configuration
- Security (conditional debugging, configurable CORS)
- Testing and code quality
- Containerization
- Cloud deployment

## Project Structure

```
.
├── src/                        # Application source code
│   ├── main.py                 # Application entry point
│   ├── config.py               # Configuration management
│   ├── api/                    # API endpoints
│   │   ├── __init__.py         # API module exports
│   │   ├── health.py           # Health check endpoint
│   │   └── hello.py            # Example endpoints
│   └── tests/                  # Test suite
│       ├── __init__.py
│       └── test_api.py         # API tests
├── docs/                       # Documentation (you are here!)
├── .github/workflows/          # CI/CD workflows
│   └── ci.yaml                 # Continuous Integration
├── Dockerfile.dev              # Development container
├── Dockerfile.prod             # Production container
├── docker-compose.dev.yaml     # Dev environment with Docker Compose
├── docker-compose.yaml         # Prod environment with Docker Compose
├── requirements.txt            # Python dependencies
├── requirements-dev.txt        # Development dependencies
├── pyproject.toml              # Tool configurations (ruff, black, mypy, pytest)
├── .env.example                # Environment variable template
└── .gitignore                  # Git ignore patterns
```

## Core Components

### 1. Application Entry Point (`src/main.py`)

**Purpose**: Initializes the FastAPI application with all middleware, routes, and configuration.

**Key Features**:
```python
# Conditional debugging (security)
if settings.DEBUG:
    import debugpy
    debugpy.listen(("0.0.0.0", 5678))

# FastAPI app initialization
app = FastAPI(
    title="FastAPI Cloud Deployment",
    description="Production-ready FastAPI application",
    version=settings.API_VERSION,
    docs_url=f"{settings.API_PREFIX}/docs",
    redoc_url=f"{settings.API_PREFIX}/redoc",
)

# CORS middleware (environment-based)
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,  # From environment
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include API routers
app.include_router(health.router, prefix=settings.API_PREFIX, tags=["health"])
app.include_router(hello.router, prefix=settings.API_PREFIX, tags=["hello"])
```

**Security Notes**:
- **Debugpy** only loads when `DEBUG=true` (not in production)
- **CORS origins** configured via environment variable (not hardcoded)
- **API prefix** allows versioning (e.g., `/api/v1`)

### 2. Configuration Management (`src/config.py`)

**Purpose**: Centralized environment-based configuration using the singleton pattern.

**Why This Matters**:
- Single source of truth for all settings
- Environment variables for different deployments
- Type-safe configuration with `@property` decorators
- Cached with `@lru_cache` for performance

```python
class Settings:
    # Application
    ENVIRONMENT: str = os.getenv("ENVIRONMENT", "development")
    DEBUG: bool = os.getenv("DEBUG", "false").lower() == "true"

    # CORS
    CORS_ORIGINS: list[str] = os.getenv("CORS_ORIGINS", "*").split(",")

    # API
    API_PREFIX: str = os.getenv("API_PREFIX", "/api")
    API_VERSION: str = os.getenv("API_VERSION", "1.0.0")

    @property
    def is_production(self) -> bool:
        return self.ENVIRONMENT == "production"

@lru_cache
def get_settings() -> Settings:
    return Settings()
```

**Usage**:
```python
from src.config import get_settings

settings = get_settings()
if settings.is_production:
    # Production-specific logic
```

### 3. API Endpoints

#### Health Check (`src/api/health.py`)

**Purpose**: Standard health check endpoint for monitoring and load balancers.

```python
@router.get("/health", response_model=HealthResponse)
async def get_health() -> HealthResponse:
    """Health check endpoint for monitoring."""
    return HealthResponse(status="healthy", message="OK")
```

**Use Cases**:
- Kubernetes liveness/readiness probes
- Load balancer health checks
- Monitoring systems
- Status pages

#### Hello World (`src/api/hello.py`)

**Purpose**: Example endpoints demonstrating FastAPI features.

```python
@router.get("/hello", response_model=HelloResponse)
async def get_hello() -> HelloResponse:
    """Simple hello world endpoint."""
    return HelloResponse(message="Hello, World!")

@router.get("/hello/{name}", response_model=HelloResponse)
async def get_hello_name(name: str) -> HelloResponse:
    """Personalized hello endpoint with path parameter."""
    return HelloResponse(message=f"Hello, {name}!")
```

**Features Demonstrated**:
- Path parameters (`{name}`)
- Response models (Pydantic)
- Type hints
- Docstrings (appear in API docs)
- Async handlers

### 4. Response Models (Pydantic)

**Purpose**: Data validation, serialization, and automatic API documentation.

```python
class HealthResponse(BaseModel):
    """Health check response model."""
    status: str
    message: str

class HelloResponse(BaseModel):
    """Hello endpoint response model."""
    message: str
```

**Benefits**:
- Automatic validation
- Type safety
- JSON serialization
- OpenAPI schema generation
- Interactive documentation

## How It Works

### Request Flow

```
1. HTTP Request arrives at port 8080
   ↓
2. Uvicorn ASGI server receives request
   ↓
3. FastAPI processes request
   ↓
4. CORS middleware checks origin (if applicable)
   ↓
5. Router matches URL to endpoint
   ↓
6. Pydantic validates path parameters
   ↓
7. Endpoint handler executes
   ↓
8. Response model validates output
   ↓
9. JSON response sent to client
```

### Startup Sequence

**Development (with Docker Compose)**:
```
1. Docker Compose reads docker-compose.dev.yaml
2. Builds image from Dockerfile.dev
3. Mounts ./src to /code/src (volume)
4. Sets environment variables
5. Starts uvicorn with --reload
6. Uvicorn watches for file changes
7. Application loads settings from environment
8. FastAPI initializes with middleware and routes
9. Server listens on 0.0.0.0:8080
```

**Production**:
```
1. Docker builds image from Dockerfile.prod
2. Copies source code into image
3. No volume mounts (immutable)
4. Starts with python -m src.main
5. Application loads production settings
6. FastAPI initializes
7. Server listens on 0.0.0.0:8080
```

## Environment Variables

Configure the application for different environments:

### Development
```bash
ENVIRONMENT=development
DEBUG=true
CORS_ORIGINS=*
LOG_LEVEL=DEBUG
API_PREFIX=/api
API_VERSION=1.0.0
HOST=0.0.0.0
PORT=8080
```

### Production
```bash
ENVIRONMENT=production
DEBUG=false
CORS_ORIGINS=https://example.com,https://www.example.com
LOG_LEVEL=INFO
API_PREFIX=/api
API_VERSION=1.0.0
HOST=0.0.0.0
PORT=8080
```

### Security Implications

**DEBUG=true in Production**:
- ❌ Exposes debugger on network
- ❌ Allows remote code execution
- ✅ Our code prevents this with conditional import

**CORS_ORIGINS=\* in Production**:
- ❌ Allows requests from any domain
- ❌ Cross-site request forgery risk
- ✅ Our code makes this configurable

## API Documentation

FastAPI automatically generates interactive API documentation:

### Swagger UI
- URL: `http://localhost:8080/api/docs`
- Features:
  - Try out endpoints directly
  - See request/response schemas
  - View examples
  - Test with different parameters

### ReDoc
- URL: `http://localhost:8080/api/redoc`
- Features:
  - Clean, readable documentation
  - Three-panel layout
  - Search functionality
  - Downloadable specs

### OpenAPI Schema
- URL: `http://localhost:8080/openapi.json`
- Machine-readable API specification
- Use with code generators
- Import into Postman/Insomnia

## Testing

### Test Structure

```python
# src/tests/test_api.py
import os
from fastapi.testclient import TestClient

# Set test environment before importing app
os.environ["ENVIRONMENT"] = "testing"
os.environ["DEBUG"] = "false"

from src.main import app

client = TestClient(app)

def test_root_endpoint():
    response = client.get("/")
    assert response.status_code == 200
    assert "message" in response.json()
```

### Running Tests

```bash
# Run all tests
pytest src/tests/

# Run with coverage
pytest src/tests/ --cov=src --cov-report=term-missing

# Run specific test
pytest src/tests/test_api.py::test_health_endpoint -v
```

### Test Coverage

Current coverage: **91%**

```
src/api/__init__.py       100%
src/api/health.py         100%
src/api/hello.py          100%
src/config.py              90%
src/main.py                81%
```

## Code Quality Tools

### Linting (Ruff)
```bash
# Check for issues
ruff check src/

# Auto-fix issues
ruff check src/ --fix
```

### Formatting (Black)
```bash
# Format code
black src/

# Check formatting
black --check src/
```

### Type Checking (MyPy)
```bash
# Check types
mypy src/
```

All configured in `pyproject.toml`.

## Adding New Endpoints

### 1. Create a new router file

```python
# src/api/users.py
from fastapi import APIRouter
from pydantic import BaseModel

router = APIRouter()

class User(BaseModel):
    id: int
    name: str

@router.get("/users/{user_id}", response_model=User)
async def get_user(user_id: int) -> User:
    """Get user by ID."""
    return User(id=user_id, name="Example User")
```

### 2. Export from `__init__.py`

```python
# src/api/__init__.py
from . import health, hello, users

__all__ = ["health", "hello", "users"]
```

### 3. Include in main app

```python
# src/main.py
from .api import health, hello, users

app.include_router(users.router, prefix=settings.API_PREFIX, tags=["users"])
```

### 4. Add tests

```python
# src/tests/test_api.py
def test_get_user():
    response = client.get("/api/users/1")
    assert response.status_code == 200
    data = response.json()
    assert data["id"] == 1
```

## Best Practices Implemented

✅ **Security**:
- Conditional debugging
- Environment-based CORS
- No secrets in code

✅ **Code Quality**:
- Type hints throughout
- Comprehensive docstrings
- Pydantic models for validation
- Tests with good coverage

✅ **Configuration**:
- Centralized in config.py
- Environment-based
- Singleton pattern with caching

✅ **Structure**:
- Clear separation of concerns
- Modular routers
- Tests alongside code

✅ **Developer Experience**:
- Auto-reload in development
- Volume mounts for instant changes
- Interactive API documentation
- Comprehensive error messages

## Common Patterns

### Dependency Injection

```python
from fastapi import Depends
from src.config import Settings, get_settings

@router.get("/info")
async def get_info(settings: Settings = Depends(get_settings)):
    return {"environment": settings.ENVIRONMENT}
```

### Error Handling

```python
from fastapi import HTTPException

@router.get("/users/{user_id}")
async def get_user(user_id: int):
    if user_id < 1:
        raise HTTPException(status_code=400, detail="Invalid user ID")
    # ... fetch user
```

### Async vs Sync

```python
# Async (preferred for I/O operations)
@router.get("/async")
async def async_handler():
    result = await some_async_operation()
    return result

# Sync (for CPU-bound or blocking operations)
@router.get("/sync")
def sync_handler():
    result = some_blocking_operation()
    return result
```

## Next Steps

- Review [Development Guide](./development.md) for local development workflow
- Check [Docker Guide](./docker.md) for containerization details
- See [API Reference](./api-reference.md) for complete endpoint documentation
- Explore cloud deployment branches for production deployment
