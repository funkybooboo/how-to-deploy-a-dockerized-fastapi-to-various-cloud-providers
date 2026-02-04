# Understanding FastAPI: Framework and Code Walkthrough

This tutorial explains how FastAPI works and walks through our application's code.

## What is FastAPI?

**FastAPI** is a modern Python web framework for building APIs. Key features:

- **Fast**: High performance, comparable to NodeJS and Go
- **Type hints**: Uses Python type hints for validation and documentation
- **Automatic docs**: Interactive API documentation generated automatically
- **Standards-based**: Built on OpenAPI and JSON Schema
- **Async support**: Native async/await for concurrent operations

### Why FastAPI?

Compared to other Python frameworks:

| Feature | FastAPI | Flask | Django |
|---------|---------|-------|--------|
| Performance | ⚡ Very Fast | 🐢 Slow | 🐢 Slow |
| Type Safety | ✅ Built-in | ❌ No | ❌ No |
| Auto Docs | ✅ Yes | ❌ No | ⚠️  Manual |
| Async | ✅ Native | ⚠️  Limited | ⚠️  Limited |
| Learning Curve | 📘 Moderate | 📗 Easy | 📕 Complex |

## Core Concepts

### 1. ASGI Application

FastAPI is an **ASGI** (Asynchronous Server Gateway Interface) application:

```python
from fastapi import FastAPI

app = FastAPI()  # This is the ASGI application
```

The `app` object is what gets run by Uvicorn (the ASGI server).

### 2. Route Decorators

Routes define which URLs map to which functions:

```python
@app.get("/")              # Decorator specifies HTTP method and path
async def root():          # Function name can be anything
    return {"message": "Hello"}  # Return value becomes JSON response
```

**HTTP Methods:**
- `@app.get()` - Read data
- `@app.post()` - Create data
- `@app.put()` - Update data (full replace)
- `@app.patch()` - Update data (partial)
- `@app.delete()` - Delete data

### 3. Path Parameters

Capture variables from the URL:

```python
@app.get("/hello/{name}")
async def get_hello(name: str):  # name comes from URL
    return {"message": f"Hello, {name}!"}
```

Visit `/hello/World` → receives `name="World"`

### 4. Pydantic Models

Define data structures with automatic validation:

```python
from pydantic import BaseModel

class HelloResponse(BaseModel):
    message: str

@app.get("/hello", response_model=HelloResponse)
async def get_hello() -> HelloResponse:
    return HelloResponse(message="Hello, World!")
```

**Benefits:**
- Type checking at runtime
- Automatic JSON serialization
- Generates OpenAPI schema for documentation
- Data validation (wrong types get rejected)

### 5. Dependency Injection

Share code across endpoints:

```python
from functools import lru_cache

@lru_cache()
def get_settings():
    return Settings()

@app.get("/info")
async def info(settings: Settings = Depends(get_settings)):
    return {"environment": settings.ENVIRONMENT}
```

FastAPI calls `get_settings()` automatically and passes the result to your function.

## Code Walkthrough

Let's explore our application file by file.

### `src/config.py` - Configuration Management

**Purpose**: Centralize all environment-based configuration.

```python
class Settings:
    ENVIRONMENT: str = os.getenv("ENVIRONMENT", "development")
    DEBUG: bool = os.getenv("DEBUG", "false").lower() == "true"
    CORS_ORIGINS: List[str] = os.getenv("CORS_ORIGINS", "*").split(",")
    # ... more settings ...

@lru_cache()
def get_settings() -> Settings:
    return Settings()
```

**How it works:**
- Reads environment variables with `os.getenv()`
- Provides defaults if variables aren't set
- `@lru_cache()` ensures Settings is created only once (singleton pattern)

**Why this matters:**
- ✅ No hardcoded values in code
- ✅ Easy to change configuration per environment
- ✅ Secure (sensitive data in environment, not code)

### `src/main.py` - Application Entry Point

**Purpose**: Initialize FastAPI and configure middleware.

Let's break it down section by section:

#### 1. Imports and Settings

```python
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from .config import get_settings
from .api import health, hello

settings = get_settings()
```

- Imports FastAPI and middleware
- Imports our configuration
- Imports API router modules
- Gets settings instance

#### 2. Conditional Debugging

```python
if settings.DEBUG:
    import debugpy
    debugpy.listen(("0.0.0.0", 5678))
    print(f"🐛 Debugger listening on port 5678")
```

**Security:** Only enables debugger when `DEBUG=true`. In production (`DEBUG=false`), this code doesn't run.

#### 3. FastAPI Application

```python
app = FastAPI(
    title="FastAPI Cloud Deployment",
    description="Production-ready FastAPI application",
    version=settings.API_VERSION,
    docs_url=f"{settings.API_PREFIX}/docs",
    redoc_url=f"{settings.API_PREFIX}/redoc",
)
```

**Parameters:**
- `title`, `description`: Shown in API documentation
- `version`: API version number
- `docs_url`: Where Swagger UI is served
- `redoc_url`: Where ReDoc documentation is served

#### 4. CORS Middleware

```python
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

**What is CORS?** Cross-Origin Resource Sharing. Browsers block requests from one domain to another unless CORS headers permit it.

**Our configuration:**
- `allow_origins`: Which domains can access our API (from environment variable)
- `allow_credentials`: Allow cookies/auth headers
- `allow_methods`: Allow all HTTP methods (GET, POST, etc.)
- `allow_headers`: Allow all headers

**Security:** In production, set `CORS_ORIGINS` to specific domains, not `*`.

#### 5. Router Registration

```python
app.include_router(health.router, prefix=settings.API_PREFIX, tags=["health"])
app.include_router(hello.router, prefix=settings.API_PREFIX, tags=["hello"])
```

**Routers** organize endpoints into modules:
- `health.router`: Health check endpoints
- `hello.router`: Hello world endpoints
- `prefix`: All routes get `/api` prefix
- `tags`: Group endpoints in documentation

#### 6. Root Endpoint

```python
@app.get("/")
async def root():
    return {
        "message": "OK 🚀",
        "version": settings.API_VERSION,
        "environment": settings.ENVIRONMENT,
    }
```

Simple health check at the root path. Returns JSON with status and config info.

### `src/api/health.py` - Health Check Endpoints

**Purpose**: Provide endpoints for monitoring service health.

```python
router = APIRouter()

class HealthResponse(BaseModel):
    status: str
    message: str

@router.get("/health", response_model=HealthResponse)
async def get_health() -> HealthResponse:
    return HealthResponse(status="healthy", message="OK")
```

**How routers work:**
- `APIRouter()` creates a sub-application
- Routes are added to the router, not the main app
- Main app includes the router with `app.include_router()`

**Full path**: `/` + `settings.API_PREFIX` + `/health` = `/api/health`

### `src/api/hello.py` - Hello World Endpoints

**Purpose**: Demonstrate basic and parameterized endpoints.

```python
@router.get("/hello", response_model=HelloResponse)
async def get_hello() -> HelloResponse:
    """Return a hello world message."""
    return HelloResponse(message="Hello, World!")

@router.get("/hello/{name}", response_model=HelloResponse)
async def get_hello_name(name: str) -> HelloResponse:
    """Return a personalized greeting."""
    return HelloResponse(message=f"Hello, {name}!")
```

**Two endpoints:**
1. `/api/hello` - Static message
2. `/api/hello/{name}` - Dynamic message with path parameter

## Request/Response Flow

Let's trace what happens when a user visits `/api/hello/Alice`:

```
1. Browser/Client
   ↓ HTTP GET /api/hello/Alice
2. Uvicorn (ASGI Server)
   ↓ Receives request, passes to FastAPI
3. FastAPI Application
   ↓ Matches route pattern /api/hello/{name}
4. FastAPI Router (hello.router)
   ↓ Finds get_hello_name() function
5. FastAPI validates and extracts:
   - Path parameter: name="Alice"
6. Function executes:
   - return HelloResponse(message=f"Hello, Alice!")
7. Pydantic serializes to JSON:
   - {"message": "Hello, Alice!"}
8. FastAPI adds headers:
   - Content-Type: application/json
9. Uvicorn sends response
   ↓
10. Browser/Client receives JSON
```

## Async vs Sync

FastAPI supports both async and regular functions:

### Async (Recommended)

```python
async def get_hello():
    # Can use await for I/O operations
    data = await fetch_from_database()
    return {"message": data}
```

**Use when:** Doing I/O (database, HTTP requests, file operations)

### Sync (Also Works)

```python
def get_hello():
    # Regular synchronous code
    return {"message": "Hello"}
```

**Use when:** Pure computation with no I/O

**Performance tip:** For I/O-bound operations (most APIs), async provides much better concurrency.

## Automatic API Documentation

FastAPI generates documentation automatically from your code.

### Swagger UI (Interactive)

Visit: `http://localhost:8080/api/docs`

Features:
- Test endpoints directly in browser
- See request/response examples
- View all available endpoints
- Auto-generated from code

### ReDoc (Reference)

Visit: `http://localhost:8080/api/redoc`

Features:
- Clean, readable documentation
- Better for printing/reading
- Same data as Swagger, different UI

### How it works:

FastAPI uses:
- Function signatures (type hints)
- Pydantic models
- Docstrings
- Route decorators

To automatically generate **OpenAPI schema**, which powers the documentation.

## Hands-On Exercise

Let's add a new endpoint together!

### Task: Add a Farewell Endpoint

**Goal:** Create `/api/farewell/{name}` that returns `{"message": "Goodbye, NAME!"}`

**Step 1:** Open `src/api/hello.py`

**Step 2:** Add this code after the existing endpoints:

```python
@router.get("/farewell/{name}", response_model=HelloResponse)
async def get_farewell(name: str) -> HelloResponse:
    """Return a farewell message."""
    return HelloResponse(message=f"Goodbye, {name}!")
```

**Step 3:** Save the file (Uvicorn auto-reloads)

**Step 4:** Test it:

```bash
curl http://localhost:8080/api/farewell/World
# Should return: {"message": "Goodbye, World!"}
```

**Step 5:** Check documentation at `http://localhost:8080/api/docs`
- Your new endpoint should appear automatically!
- Try it out using the "Try it out" button

**Step 6:** Add a test in `src/tests/test_api.py`:

```python
def test_farewell_endpoint():
    """Test farewell endpoint with name parameter."""
    response = client.get("/api/farewell/Test")
    assert response.status_code == 200
    data = response.json()
    assert data["message"] == "Goodbye, Test!"
```

**Step 7:** Run tests:

```bash
pytest src/tests/test_api.py::test_farewell_endpoint -v
```

Congratulations! You've added a new endpoint with:
- ✅ Route definition
- ✅ Type-safe response
- ✅ Automatic documentation
- ✅ Test coverage

## Key Takeaways

1. **FastAPI uses type hints** for validation and documentation
2. **Routers organize endpoints** into logical modules
3. **Pydantic models** define data structures with validation
4. **Configuration through environment variables** keeps code secure
5. **Automatic documentation** from code, no manual writing needed
6. **Async/await** enables high-concurrency applications

## Next Steps

Now you understand:
- ✅ How FastAPI applications are structured
- ✅ How requests flow through the application
- ✅ How to add new endpoints
- ✅ How to use Pydantic models
- ✅ How automatic documentation works

Continue to [05-manual-deployment.md](./05-manual-deployment.md) to learn about deploying to Google Cloud Run.

---

**Learn More:**
- FastAPI Official Tutorial: [fastapi.tiangolo.com/tutorial](https://fastapi.tiangolo.com/tutorial/)
- Pydantic Documentation: [docs.pydantic.dev](https://docs.pydantic.dev/)
- Python Async/Await: [docs.python.org/3/library/asyncio.html](https://docs.python.org/3/library/asyncio.html)
