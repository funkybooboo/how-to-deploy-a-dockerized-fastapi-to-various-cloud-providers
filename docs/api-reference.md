# API Reference

Complete reference for all API endpoints in the FastAPI application.

## Base URL

- **Local Development**: `http://localhost:8080`
- **Production**: Depends on your deployment

## API Prefix

All API endpoints are prefixed with `/api` by default.

This can be configured via the `API_PREFIX` environment variable.

## Interactive Documentation

The best way to explore and test the API is through the interactive documentation:

- **Swagger UI**: http://localhost:8080/api/docs
- **ReDoc**: http://localhost:8080/api/redoc
- **OpenAPI JSON**: http://localhost:8080/openapi.json

## Endpoints

### Root Endpoint

#### GET /

Simple health check at the root level.

**Request**:
```bash
curl http://localhost:8080/
```

**Response**: `200 OK`
```json
{
  "message": "OK 🚀",
  "version": "1.0.0",
  "environment": "development"
}
```

**Fields**:
- `message` (string): Status message
- `version` (string): API version from configuration
- `environment` (string): Current environment (development/production/testing)

---

### Health Check

#### GET /api/health

Standard health check endpoint for monitoring, load balancers, and orchestrators.

**Request**:
```bash
curl http://localhost:8080/api/health
```

**Response**: `200 OK`
```json
{
  "status": "healthy",
  "message": "OK"
}
```

**Response Model**: `HealthResponse`
- `status` (string): Health status indicator ("healthy")
- `message` (string): Human-readable message

**Use Cases**:
- Kubernetes liveness/readiness probes
- Cloud Run health checks
- Azure Container Apps health probes
- Load balancer health checks
- Monitoring systems (DataDog, New Relic, etc.)
- Status pages

**Example with curl**:
```bash
# Check if service is healthy
if curl -f http://localhost:8080/api/health; then
    echo "Service is healthy"
else
    echo "Service is down"
fi
```

---

### Hello World

#### GET /api/hello

Simple hello world endpoint demonstrating basic FastAPI functionality.

**Request**:
```bash
curl http://localhost:8080/api/hello
```

**Response**: `200 OK`
```json
{
  "message": "Hello, World!"
}
```

**Response Model**: `HelloResponse`
- `message` (string): Greeting message

---

### Hello with Name

#### GET /api/hello/{name}

Personalized greeting demonstrating path parameters.

**Path Parameters**:
- `name` (string, required): Name to greet

**Request**:
```bash
curl http://localhost:8080/api/hello/Alice
```

**Response**: `200 OK`
```json
{
  "message": "Hello, Alice!"
}
```

**Response Model**: `HelloResponse`
- `message` (string): Personalized greeting

**Examples**:
```bash
# Simple name
curl http://localhost:8080/api/hello/Bob
# Response: {"message": "Hello, Bob!"}

# Name with URL encoding (spaces, special chars)
curl http://localhost:8080/api/hello/John%20Doe
# Response: {"message": "Hello, John Doe!"}

# Unicode characters
curl http://localhost:8080/api/hello/%E4%B8%96%E7%95%8C
# Response: {"message": "Hello, 世界!"}
```

---

## Response Models

All responses are validated using Pydantic models, ensuring type safety and automatic documentation.

### HealthResponse

```python
class HealthResponse(BaseModel):
    """Health check response model."""
    status: str
    message: str
```

**Fields**:
- `status`: Health status indicator (typically "healthy")
- `message`: Human-readable status message

**JSON Schema**:
```json
{
  "type": "object",
  "properties": {
    "status": {"type": "string"},
    "message": {"type": "string"}
  },
  "required": ["status", "message"]
}
```

### HelloResponse

```python
class HelloResponse(BaseModel):
    """Hello endpoint response model."""
    message: str
```

**Fields**:
- `message`: Greeting or message string

**JSON Schema**:
```json
{
  "type": "object",
  "properties": {
    "message": {"type": "string"}
  },
  "required": ["message"]
}
```

---

## HTTP Status Codes

### Success Codes

| Code | Meaning | When Used |
|------|---------|-----------|
| 200 | OK | Successful GET request |
| 201 | Created | Successful POST request (creating resource) |
| 204 | No Content | Successful DELETE request |

### Client Error Codes

| Code | Meaning | When Used |
|------|---------|-----------|
| 400 | Bad Request | Invalid input data |
| 404 | Not Found | Resource doesn't exist |
| 422 | Unprocessable Entity | Validation error (automatic from FastAPI) |

### Server Error Codes

| Code | Meaning | When Used |
|------|---------|-----------|
| 500 | Internal Server Error | Unhandled exception |
| 503 | Service Unavailable | Service temporarily down |

---

## Error Responses

FastAPI automatically generates error responses with detailed validation information.

### Validation Error Example

**Request**:
```bash
# Missing required parameter (hypothetical endpoint)
curl -X POST http://localhost:8080/api/users \
  -H "Content-Type: application/json" \
  -d '{}'
```

**Response**: `422 Unprocessable Entity`
```json
{
  "detail": [
    {
      "loc": ["body", "name"],
      "msg": "field required",
      "type": "value_error.missing"
    }
  ]
}
```

---

## CORS (Cross-Origin Resource Sharing)

CORS is configured via environment variable for security.

### Development
```bash
CORS_ORIGINS=*  # Allow all origins
```

### Production
```bash
CORS_ORIGINS=https://example.com,https://www.example.com  # Specific domains only
```

### Preflight Requests

For CORS-enabled requests, browsers send a preflight OPTIONS request:

```bash
curl -X OPTIONS http://localhost:8080/api/hello \
  -H "Origin: https://example.com" \
  -H "Access-Control-Request-Method: GET"
```

**Response Headers**:
```
Access-Control-Allow-Origin: *
Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS
Access-Control-Allow-Headers: *
Access-Control-Allow-Credentials: true
```

---

## Rate Limiting

Currently not implemented, but can be added using:
- **slowapi**: Python rate limiting library
- **Cloud provider**: API Gateway rate limiting
- **nginx**: Upstream rate limiting

Example implementation:
```python
from slowapi import Limiter
from slowapi.util import get_remote_address

limiter = Limiter(key_func=get_remote_address)

@app.get("/api/hello")
@limiter.limit("10/minute")
async def hello():
    return {"message": "Hello, World!"}
```

---

## Authentication

Currently not implemented. When added, typical approaches:

### API Key
```bash
curl http://localhost:8080/api/resource \
  -H "X-API-Key: your-api-key"
```

### Bearer Token (JWT)
```bash
curl http://localhost:8080/api/resource \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIs..."
```

### OAuth2
FastAPI has built-in OAuth2 support with interactive docs.

---

## Versioning

API versioning can be implemented via:

### URL Path (Current)
```
/api/v1/users
/api/v2/users
```

Configure via `API_PREFIX`:
```bash
API_PREFIX=/api/v1
```

### Header-based
```bash
curl http://localhost:8080/api/users \
  -H "API-Version: 2"
```

### Content Negotiation
```bash
curl http://localhost:8080/api/users \
  -H "Accept: application/vnd.api.v2+json"
```

---

## Client Libraries

### Python (httpx)
```python
import httpx

async with httpx.AsyncClient() as client:
    response = await client.get("http://localhost:8080/api/hello")
    print(response.json())  # {"message": "Hello, World!"}
```

### Python (requests)
```python
import requests

response = requests.get("http://localhost:8080/api/hello")
print(response.json())  # {"message": "Hello, World!"}
```

### JavaScript (fetch)
```javascript
fetch('http://localhost:8080/api/hello')
  .then(response => response.json())
  .then(data => console.log(data));
```

### JavaScript (axios)
```javascript
const axios = require('axios');

axios.get('http://localhost:8080/api/hello')
  .then(response => console.log(response.data));
```

### curl
```bash
# GET request
curl http://localhost:8080/api/hello

# POST request (hypothetical)
curl -X POST http://localhost:8080/api/users \
  -H "Content-Type: application/json" \
  -d '{"name": "Alice", "email": "alice@example.com"}'

# With headers
curl http://localhost:8080/api/hello \
  -H "X-Custom-Header: value"
```

---

## Testing the API

### Using Interactive Docs

1. Open http://localhost:8080/api/docs
2. Click on an endpoint to expand
3. Click "Try it out"
4. Fill in parameters
5. Click "Execute"
6. View response

### Using curl

```bash
# Simple GET
curl http://localhost:8080/api/health

# Pretty-print JSON (with jq)
curl -s http://localhost:8080/api/hello | jq .

# View headers
curl -i http://localhost:8080/api/health

# Verbose output (debugging)
curl -v http://localhost:8080/api/health
```

### Using Python TestClient

```python
from fastapi.testclient import TestClient
from src.main import app

client = TestClient(app)

def test_hello_endpoint():
    response = client.get("/api/hello")
    assert response.status_code == 200
    assert response.json() == {"message": "Hello, World!"}
```

---

## OpenAPI Specification

The complete OpenAPI specification is available at:

**URL**: http://localhost:8080/openapi.json

Use it to:
- Generate client libraries (openapi-generator)
- Import into Postman/Insomnia
- Generate documentation
- Validate API contracts

Example using openapi-generator:
```bash
# Generate Python client
openapi-generator generate \
  -i http://localhost:8080/openapi.json \
  -g python \
  -o ./client
```

---

## Performance Tips

### Use Async Handlers

```python
# Async (better for I/O-bound operations)
@router.get("/users")
async def get_users():
    users = await db.fetch_users()  # Non-blocking
    return users
```

### Enable HTTP/2

```bash
# Run with HTTP/2 support
uvicorn src.main:app --http h11 --interface asgi3
```

### Use Connection Pooling

```python
# For database connections
from databases import Database

database = Database("postgresql://user:pass@localhost/db")

@app.on_event("startup")
async def startup():
    await database.connect()
```

---

## Next Steps

- Explore the [Application Guide](./application.md) to understand the codebase
- Review [Development Guide](./development.md) for local development
- Check [Getting Started](./getting-started.md) to run the application
- Deploy to cloud using branch-specific tutorials:
  - [GCloud Branch](../../tree/gcloud) - Google Cloud Run
  - [Azure Branch](../../tree/azure) - Azure Container Apps
