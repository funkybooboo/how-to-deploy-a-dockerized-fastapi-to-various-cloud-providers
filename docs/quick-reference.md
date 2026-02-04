# Quick Reference Guide

Fast lookup for common commands, patterns, and workflows.

## 🚀 Docker Commands

### Development

```bash
# Start development server with Docker Compose
docker-compose -f docker-compose.dev.yaml up

# Rebuild and start (after dependency changes)
docker-compose -f docker-compose.dev.yaml up --build

# Stop all containers
docker-compose -f docker-compose.dev.yaml down

# View logs
docker-compose -f docker-compose.dev.yaml logs -f app

# Execute command in running container
docker-compose -f docker-compose.dev.yaml exec app bash
```

### Production Build

```bash
# Build production image
docker build -f Dockerfile.prod -t fastapi-app:latest .

# Run production image locally
docker run -p 8080:8080 \
  -e ENVIRONMENT=production \
  -e DEBUG=false \
  fastapi-app:latest

# Build with specific tag
docker build -f Dockerfile.prod -t fastapi-app:v1.0.0 .

# Remove unused images
docker image prune -a
```

### Useful Docker Commands

```bash
# List running containers
docker ps

# List all containers (including stopped)
docker ps -a

# View container logs
docker logs <container-id> --follow

# Inspect container
docker inspect <container-id>

# Remove all stopped containers
docker container prune

# View image layers
docker history fastapi-app:latest
```

## 🧪 Testing Commands

### Run Tests

```bash
# All tests with coverage
pytest src/tests/ -v --cov=src --cov-report=term-missing

# Specific test file
pytest src/tests/test_api.py -v

# Specific test function
pytest src/tests/test_api.py::test_health_check -v

# Stop on first failure
pytest src/tests/ -x

# Run tests matching pattern
pytest src/tests/ -k "health" -v
```

### Code Quality

```bash
# Lint with ruff
ruff check src/

# Fix auto-fixable issues
ruff check src/ --fix

# Type checking
mypy src/

# Format code
black src/

# Check formatting without changing
black src/ --check
```

## 📡 API Endpoints

### Health & Status

```bash
# Health check
curl http://localhost:8080/api/health

# Root endpoint
curl http://localhost:8080/
```

### Hello Endpoint

```bash
# Simple GET
curl http://localhost:8080/api/hello

# With name parameter
curl "http://localhost:8080/api/hello?name=World"

# POST request
curl -X POST http://localhost:8080/api/hello \
  -H "Content-Type: application/json" \
  -d '{"name": "FastAPI"}'
```

### Interactive Documentation

- **Swagger UI**: http://localhost:8080/api/docs
- **ReDoc**: http://localhost:8080/api/redoc
- **OpenAPI JSON**: http://localhost:8080/api/openapi.json

## 🔧 Common Patterns

### Environment Variables

```bash
# Development (.env file)
ENVIRONMENT=development
DEBUG=true
LOG_LEVEL=DEBUG
CORS_ORIGINS=http://localhost:3000,http://localhost:8080

# Production
ENVIRONMENT=production
DEBUG=false
LOG_LEVEL=INFO
CORS_ORIGINS=https://yourdomain.com
```

### Adding New Endpoint

1. Create new file in `src/api/` (e.g., `users.py`)
2. Define route function with FastAPI decorators
3. Import and include router in `src/main.py`
4. Add tests in `src/tests/`
5. Run tests to verify

```python
# src/api/users.py
from fastapi import APIRouter

router = APIRouter(prefix="/api/users", tags=["users"])

@router.get("/")
async def get_users():
    return {"users": []}

# src/main.py
from src.api import users
app.include_router(users.router)
```

### Volume Mounts (Development)

```yaml
# docker-compose.dev.yaml
volumes:
  - ./src:/app/src:ro  # Read-only source code
  - ./requirements.txt:/app/requirements.txt:ro
  - ./requirements-dev.txt:/app/requirements-dev.txt:ro
```

## 🐛 Debugging

### Check What's Running

```bash
# See all processes
docker-compose -f docker-compose.dev.yaml ps

# Check port bindings
docker port <container-name>

# Verify container health
docker inspect <container-id> | grep -A 5 Health
```

### Common Issues

**Port already in use:**
```bash
# Find what's using port 8080
lsof -i :8080
# or on Windows:
netstat -ano | findstr :8080

# Kill the process or change port in docker-compose
```

**Container exits immediately:**
```bash
# View logs
docker-compose -f docker-compose.dev.yaml logs app

# Check for syntax errors
docker-compose -f docker-compose.dev.yaml config
```

**Dependencies not installing:**
```bash
# Rebuild without cache
docker-compose -f docker-compose.dev.yaml build --no-cache
```

## 📁 Project Structure Quick Reference

```
├── src/
│   ├── main.py              # App entry point
│   ├── config.py            # Configuration
│   ├── api/                 # API endpoints
│   │   ├── health.py
│   │   └── hello.py
│   └── tests/               # Test suite
│       └── test_api.py
├── Dockerfile.dev           # Development container
├── Dockerfile.prod          # Production container
├── docker-compose.dev.yaml  # Dev environment
├── requirements.txt         # Python dependencies
└── requirements-dev.txt     # Dev dependencies
```

## ⚡ Pro Tips

### Speed Up Builds

- Use `.dockerignore` to exclude unnecessary files
- Layer dependencies before source code
- Use multi-stage builds for production
- Cache pip packages

### Development Workflow

1. Make code changes
2. Save file → auto-reload happens
3. Test in browser or with curl
4. Run tests: `pytest src/tests/`
5. Commit when tests pass

### Before Deployment

```bash
# Run full test suite
pytest src/tests/ -v --cov=src

# Check code quality
ruff check src/
mypy src/
black src/ --check

# Build production image
docker build -f Dockerfile.prod -t myapp:prod .

# Test production image locally
docker run -p 8080:8080 myapp:prod
```

---

**See Also**:
- [Development Guide](./development.md) - Full development workflow
- [Docker Guide](./docker.md) - Deep dive into Docker
- [API Reference](./api-reference.md) - Complete API documentation
