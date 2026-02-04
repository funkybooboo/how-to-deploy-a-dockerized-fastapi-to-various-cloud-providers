# Docker Guide

Comprehensive guide to Docker containerization for this FastAPI application.

## Overview

Two Docker configurations for different purposes:
- **Dockerfile.dev** - Development with tools and live reload (~606MB)
- **Dockerfile.prod** - Production optimized multi-stage build (~196MB)

## Dockerfile.dev - Development Container

### Complete File

```dockerfile
FROM python:3.12-slim

# Development tools
RUN apt-get update && apt-get install -y \
    curl git vim net-tools build-essential

WORKDIR /code
ENV PYTHONPATH=/code/src

# Dependencies (cached layer)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Source code
COPY ./src ./src

EXPOSE 8080
CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8080", "--reload"]
```

### Key Concepts

**Layer Caching**: Dependencies copied before code
- Code changes → don't rebuild dependencies
- Faster builds during development

**PYTHONPATH**: Set to `/code/src` for imports
- Allows `from src.main import app`
- Critical for module resolution

**--reload Flag**: Uvicorn watches for changes
- Edit code → server auto-restarts
- Works with volume mounts

### Usage

```bash
# Build
docker build -f Dockerfile.dev -t fastapi-dev .

# Run with volume mount
docker run -p 8080:8080 \
  -v $(pwd)/src:/code/src \
  fastapi-dev
```

**Better**: Use docker-compose.dev.yaml instead

## Dockerfile.prod - Production Container

### Complete File

```dockerfile
# Stage 1: Build
FROM python:3.12-slim as builder

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

# Stage 2: Runtime
FROM python:3.12-slim

WORKDIR /app

# Copy only installed packages
COPY --from=builder /root/.local /root/.local
ENV PATH=/root/.local/bin:$PATH
ENV PYTHONPATH=/app

# Copy application code
COPY ./src ./src

# Non-root user
RUN useradd -m -u 1000 appuser && chown -R appuser:appuser /app
USER appuser

EXPOSE 8080
CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8080"]
```

### Multi-Stage Build Benefits

**Stage 1 (builder)**:
- Installs dependencies with pip
- Can include build tools if needed
- Gets thrown away after build

**Stage 2 (runtime)**:
- Only copies installed packages
- No pip, no build tools
- Much smaller final image (196MB vs 606MB)

**Why it matters**:
- Faster deployments (smaller upload)
- Reduced attack surface (fewer packages)
- Lower cloud costs (less storage, faster scaling)

### Production Features

**No --reload**: Stable production server
**Non-root user**: Security best practice
**No dev tools**: Minimal attack surface
**Optimized**: Only what's needed to run

### Usage

```bash
# Build
docker build -f Dockerfile.prod -t fastapi-prod .

# Run
docker run -p 8080:8080 \
  -e ENVIRONMENT=production \
  -e DEBUG=false \
  fastapi-prod
```

## Docker Compose

### Development (docker-compose.dev.yaml)

```yaml
services:
  fastapi-dev:
    build:
      dockerfile: Dockerfile.dev
    ports:
      - "8080:8080"
    volumes:
      - ./src:/code/src  # Live code editing
    environment:
      - DEBUG=true
      - ENVIRONMENT=development
    restart: unless-stopped
```

**Start**: `docker-compose -f docker-compose.dev.yaml up`

### Production (docker-compose.yaml)

```yaml
services:
  fastapi-prod:
    build:
      dockerfile: Dockerfile.prod
    ports:
      - "8080:8080"
    environment:
      - DEBUG=false
      - ENVIRONMENT=production
    restart: unless-stopped
```

**Start**: `docker-compose up`

## Volume Mounts

### How They Work

```yaml
volumes:
  - ./src:/code/src
    ↑         ↑
    Host      Container
```

Changes on either side appear on both sides immediately.

```
Edit locally → File updates in container → Uvicorn reloads → Changes live
```

### When to Use

**Use volumes for**:
- Source code during development
- Configuration files you edit frequently
- Logs you want to access easily

**Don't use volumes for**:
- Production deployments (immutable images)
- Dependencies (slow, use layer caching)
- Temporary files (use tmpfs instead)

## Best Practices

### Development

- **Use docker-compose.dev.yaml** - Simpler than manual commands
- **Mount only src/** - Not the entire project
- **Layer dependencies first** - Cache pip installs
- **Use --reload** - Auto-restart on changes

### Production

- **Multi-stage builds** - Smaller images
- **Non-root user** - Security
- **No dev dependencies** - requirements.txt only
- **Explicit versions** - Pin Python, packages
- **Health checks** - Monitor container status
- **.dockerignore** - Exclude unnecessary files

### General

- **One process per container** - Not multiple services
- **Immutable infrastructure** - Rebuild don't patch
- **Environment variables** - Not hardcoded config
- **Log to stdout** - Docker captures logs

## Multi-Stage Builds Deep Dive

### Pattern

```dockerfile
# Stage 1: Build environment
FROM base AS builder
# Install build tools
# Compile/build application

# Stage 2: Runtime environment
FROM base
# Copy only artifacts from builder
# No build tools in final image
```

### Benefits

| Aspect | Single-Stage | Multi-Stage |
|--------|--------------|-------------|
| Image size | ~600MB | ~200MB |
| Build tools | Included | Excluded |
| Security | Lower | Higher |
| Deploy speed | Slower | Faster |

### When to Use

**Multi-stage for**:
- Production images
- Applications with build steps (compile, bundle, etc.)
- When size/security matters

**Single-stage for**:
- Development (need tools)
- Simple Python apps (no compilation)
- When simplicity > optimization

## Security

### Run as Non-Root

```dockerfile
RUN useradd -m -u 1000 appuser
USER appuser
```

**Why**: Limits damage if container is compromised

### Scan for Vulnerabilities

```bash
# Using Docker Scout
docker scout cves fastapi-prod:latest

# Using Trivy
trivy image fastapi-prod:latest
```

### Minimal Base Images

```dockerfile
python:3.12-slim      # Good (smaller)
python:3.12-alpine    # Better (smallest, but compatibility issues)
python:3.12           # Avoid (huge, unnecessary)
```

## Troubleshooting

**Build fails**: Check Dockerfile syntax, network for downloads

**Container exits immediately**: Check logs with `docker logs <container-id>`

**Volume changes not detected**: Verify mount path, restart container

**Permission errors**: Use same UID/GID as host user

**Port already in use**: Find process with `lsof -i :8080` and kill it

See [Quick Reference](./quick-reference.md) for commands and [Development Guide](./development.md) for workflow help.

## Cloud Deployment Notes

**Google Cloud Run**:
- Uses Dockerfile.prod automatically
- Scales to zero (cost-effective)
- Max request timeout: 60 minutes

**Azure Container Apps**:
- Supports both Dockerfile types
- Scale to zero available
- Integrated with Azure ecosystem

**AWS ECS/Fargate**:
- Use Dockerfile.prod
- Push to ECR (Elastic Container Registry)
- Task definitions configure resources

See cloud-specific branches for detailed deployment guides.

## Next Steps

- **Development**: See [Development Guide](./development.md)
- **Commands**: See [Quick Reference](./quick-reference.md)
- **Deploy**: Check cloud-specific branches (gcloud, azure)
- **Advanced**: Explore Kubernetes deployments

---

**Pro Tip**: Master docker-compose for development, multi-stage builds for production.
