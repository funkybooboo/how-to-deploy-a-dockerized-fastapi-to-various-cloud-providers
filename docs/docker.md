# Docker Guide

Comprehensive guide to the Docker containerization setup for this FastAPI application.

## Overview

This project includes two Docker configurations:
- **Dockerfile.dev** - Development container with tools and live reload
- **Dockerfile.prod** - Production container optimized for deployment

## Dockerfile.dev - Development Container

### Purpose
Development environment with:
- Development tools (git, vim, build-essential)
- Live code reload with volume mounts
- Debug capabilities
- Larger image size (~606MB) for convenience

### Complete Dockerfile
```dockerfile
# Use official Python slim image
FROM python:3.12-slim

# Install essential tools for development
RUN apt-get update && apt-get install -y \
    apt-transport-https \
    ca-certificates \
    gnupg \
    curl \
    git \
    vim \
    net-tools \
    build-essential

# Set working directory
WORKDIR /code

# Set PYTHONPATH so imports work
ENV PYTHONPATH=/code/src

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy source code
COPY ./src ./src

# Expose default dev port
EXPOSE 8080

# Start server with auto-reload for development
CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8080", "--reload"]
```

### Layer-by-Layer Explanation

**1. Base Image**
```dockerfile
FROM python:3.12-slim
```
- Official Python image
- `slim` variant: minimal size, no unnecessary packages
- Python 3.12: modern, performant

**2. Development Tools**
```dockerfile
RUN apt-get update && apt-get install -y \
    apt-transport-https \  # HTTPS support
    ca-certificates \      # SSL certificates
    gnupg \                # GPG for package verification
    curl \                 # Download files
    git \                  # Version control
    vim \                  # Text editor
    net-tools \            # Network debugging
    build-essential        # C compiler for some Python packages
```

**3. Working Directory**
```dockerfile
WORKDIR /code
```
- All subsequent commands run from `/code`
- Code lives in `/code/src`

**4. PYTHONPATH**
```dockerfile
ENV PYTHONPATH=/code/src
```
- Allows imports like `from src.main import app`
- Critical for module resolution

**5. Dependencies**
```dockerfile
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
```
- Copy requirements first (Docker layer caching)
- Install before copying code
- If code changes, don't reinstall dependencies

**6. Source Code**
```dockerfile
COPY ./src ./src
```
- Copies at build time
- Overridden by volume mount in docker-compose

**7. Port Exposure**
```dockerfile
EXPOSE 8080
```
- Documents which port the app uses
- Doesn't actually publish the port (use `-p` flag)

**8. Start Command**
```dockerfile
CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8080", "--reload"]
```
- `--host 0.0.0.0`: Listen on all interfaces (required in container)
- `--port 8080`: Application port
- `--reload`: Auto-reload on file changes

### Usage

**Build**:
```bash
docker build -f Dockerfile.dev -t fastapi-dev .
```

**Run with volume mount** (recommended):
```bash
docker run -d \
  -p 8080:8080 \
  -v $(pwd)/src:/code/src \
  -e DEBUG=true \
  --name fastapi-dev \
  fastapi-dev
```

**Run with Docker Compose** (best):
```bash
docker-compose -f docker-compose.dev.yaml up
```

## Dockerfile.prod - Production Container

### Purpose
Production-optimized container:
- Minimal size (~164MB)
- No development tools
- Immutable (code baked in)
- Security hardened
- Fast startup

### Complete Dockerfile
```dockerfile
FROM python:3.12-slim

ENV PYTHONUNBUFFERED=1

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY ./src ./src

EXPOSE 8080

# Run as module to preserve relative imports
CMD ["python", "-m", "src.main"]
```

### Layer-by-Layer Explanation

**1. Base Image**
```dockerfile
FROM python:3.12-slim
```
- Same base as dev (consistency)
- Slim = minimal production footprint

**2. Unbuffered Output**
```dockerfile
ENV PYTHONUNBUFFERED=1
```
- Forces stdout/stderr to be unbuffered
- Logs appear immediately (critical for cloud platforms)
- Without this, logs may be delayed or lost

**3. Working Directory**
```dockerfile
WORKDIR /app
```
- Different from dev (`/app` vs `/code`)
- Cleaner production path

**4. Dependencies**
```dockerfile
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
```
- Same pattern as dev
- `--no-cache-dir`: Saves space (no pip cache)

**5. Source Code**
```dockerfile
COPY ./src ./src
```
- Code is immutable (baked into image)
- No volume mounts in production

**6. Port Exposure**
```dockerfile
EXPOSE 8080
```
- Documents port usage

**7. Start Command**
```dockerfile
CMD ["python", "-m", "src.main"]
```
- Runs as Python module
- No `--reload` flag (production)
- Handles Python path correctly

### Usage

**Build**:
```bash
docker build -f Dockerfile.prod -t fastapi-prod .
```

**Run**:
```bash
docker run -d \
  -p 8080:8080 \
  -e DEBUG=false \
  -e ENVIRONMENT=production \
  --name fastapi-prod \
  fastapi-prod
```

**Run with Docker Compose**:
```bash
docker-compose up
```

## Docker Compose Files

### docker-compose.dev.yaml

**Purpose**: Simplify development workflow with volume mounts

```yaml
version: '3.8'

services:
  fastapi-dev:
    build:
      context: .
      dockerfile: Dockerfile.dev
    ports:
      - "8080:8080"
    volumes:
      # Live code editing
      - ./src:/code/src
      - ./requirements.txt:/code/requirements.txt
    environment:
      - DEBUG=true
      - ENVIRONMENT=development
      - CORS_ORIGINS=*
      - LOG_LEVEL=DEBUG
    restart: unless-stopped
    command: uvicorn src.main:app --host 0.0.0.0 --port 8080 --reload
```

**Key Features**:
- **volumes**: Mount local code into container
- **environment**: Development settings
- **restart**: Auto-restart on failure
- **command**: Override Dockerfile CMD if needed

### docker-compose.yaml

**Purpose**: Production-like local environment

```yaml
version: '3.8'

services:
  fastapi-prod:
    build:
      context: .
      dockerfile: Dockerfile.prod
    ports:
      - "8080:8080"
    environment:
      - DEBUG=false
      - ENVIRONMENT=production
      - CORS_ORIGINS=https://example.com
      - LOG_LEVEL=INFO
    restart: unless-stopped
```

**Key Features**:
- No volume mounts (immutable)
- Production environment variables
- Minimal configuration

## Volume Mounts Explained

### What is a Volume Mount?

```yaml
volumes:
  - ./src:/code/src
```

- **Left** (`./src`): Path on your computer
- **Right** (`/code/src`): Path inside container
- Changes on either side reflect immediately
- Like a "window" from container to your filesystem

### How It Works

```
Your Computer                 Docker Container
┌─────────────┐              ┌─────────────┐
│  ./src/     │◄────────────►│  /code/src/ │
│    main.py  │   mounted    │    main.py  │
│    api/     │              │    api/     │
└─────────────┘              └─────────────┘

Edit main.py locally ──► Changes appear in container ──► Uvicorn reloads
```

### Types of Mounts

**Bind Mount** (what we use):
```yaml
volumes:
  - ./src:/code/src  # Specific directory
```

**Named Volume**:
```yaml
volumes:
  - app-data:/app/data  # Managed by Docker
```

## Docker Commands Cheat Sheet

### Building

```bash
# Build dev container
docker build -f Dockerfile.dev -t fastapi-dev .

# Build prod container
docker build -f Dockerfile.prod -t fastapi-prod .

# Build with no cache (fresh build)
docker build --no-cache -f Dockerfile.dev -t fastapi-dev .

# Build with Docker Compose
docker-compose -f docker-compose.dev.yaml build
```

### Running

```bash
# Run dev container with volume mount
docker run -d -p 8080:8080 -v $(pwd)/src:/code/src fastapi-dev

# Run prod container
docker run -d -p 8080:8080 -e ENVIRONMENT=production fastapi-prod

# Run with Docker Compose
docker-compose -f docker-compose.dev.yaml up
docker-compose -f docker-compose.dev.yaml up -d  # Detached

# Run and rebuild
docker-compose -f docker-compose.dev.yaml up --build
```

### Managing

```bash
# List running containers
docker ps

# List all containers
docker ps -a

# View logs
docker logs fastapi-dev
docker logs -f fastapi-dev  # Follow logs
docker-compose -f docker-compose.dev.yaml logs -f

# Stop container
docker stop fastapi-dev
docker-compose -f docker-compose.dev.yaml stop

# Start stopped container
docker start fastapi-dev

# Remove container
docker rm fastapi-dev

# Stop and remove
docker stop fastapi-dev && docker rm fastapi-dev
docker-compose -f docker-compose.dev.yaml down
```

### Inspecting

```bash
# Execute command in running container
docker exec -it fastapi-dev bash
docker exec fastapi-dev ps aux
docker exec fastapi-dev ls -la /code/src

# Inspect container
docker inspect fastapi-dev

# View container stats
docker stats fastapi-dev

# View image details
docker images
docker image inspect fastapi-dev
```

### Cleaning Up

```bash
# Remove unused containers
docker container prune

# Remove unused images
docker image prune

# Remove unused volumes
docker volume prune

# Nuclear option (remove everything)
docker system prune -a
```

## Best Practices

### Development Container

✅ **Do**:
- Use volume mounts for live editing
- Include development tools
- Enable auto-reload
- Use larger base images for convenience

❌ **Don't**:
- Use in production
- Worry about image size
- Disable auto-reload

### Production Container

✅ **Do**:
- Minimize image size
- Remove development tools
- Use multi-stage builds (if needed)
- Set PYTHONUNBUFFERED=1
- Use specific image versions

❌ **Don't**:
- Include development dependencies
- Use volume mounts
- Run as root (add USER directive if needed)
- Include secrets in image

### General

✅ **Do**:
- Use .dockerignore to exclude files
- Leverage layer caching (COPY requirements first)
- Use slim base images
- Document exposed ports
- Tag images meaningfully

❌ **Don't**:
- Store secrets in images
- Use latest tag in production
- Run unnecessary services
- Ignore security updates

## Multi-Stage Builds (Advanced)

If you need to compile dependencies but want a small final image:

```dockerfile
# Stage 1: Build stage
FROM python:3.12 as builder

WORKDIR /build
COPY requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

# Stage 2: Runtime stage
FROM python:3.12-slim

COPY --from=builder /root/.local /root/.local
ENV PATH=/root/.local/bin:$PATH

WORKDIR /app
COPY ./src ./src

EXPOSE 8080
CMD ["python", "-m", "src.main"]
```

Benefits:
- Smaller final image
- Build tools not in production
- Faster deployments

## Security Considerations

### Running as Non-Root

Add to Dockerfile:
```dockerfile
RUN useradd -m -u 1000 appuser
USER appuser
```

### Scanning for Vulnerabilities

```bash
# Install trivy
brew install trivy  # Mac
# or apt-get install trivy  # Linux

# Scan image
trivy image fastapi-prod

# Scan with severity filter
trivy image --severity HIGH,CRITICAL fastapi-prod
```

### Minimal Base Images

Consider alternatives:
- `python:3.12-slim` - Current choice (good balance)
- `python:3.12-alpine` - Even smaller (~50MB) but may have compatibility issues
- `distroless/python3` - Google's minimal images (no shell)

## Troubleshooting

### Container Won't Start

```bash
# View logs
docker logs fastapi-dev

# Check if port is in use
lsof -i :8080

# Inspect container
docker inspect fastapi-dev

# Try running interactively
docker run -it --rm -p 8080:8080 fastapi-dev bash
```

### Volume Mount Not Working

```bash
# Verify mount inside container
docker exec fastapi-dev ls -la /code/src

# Check permissions (Linux)
ls -la ./src

# Try absolute path
docker run -v /absolute/path/to/src:/code/src ...
```

### Changes Not Detected

```bash
# Verify uvicorn is running with --reload
docker exec fastapi-dev ps aux | grep uvicorn

# Restart container
docker restart fastapi-dev

# Check logs for errors
docker logs -f fastapi-dev
```

## Cloud Platform Specifics

### Google Cloud Run
- Uses Dockerfile.prod
- Must listen on $PORT environment variable
- Modify CMD: `CMD python -m src.main`
- Set PORT=8080 in environment

### Azure Container Apps
- Uses Dockerfile.prod
- Similar to Cloud Run
- Configure port in portal

### AWS ECS/Fargate
- Uses Dockerfile.prod
- Configure port mapping in task definition
- Can use secrets manager for environment variables

## Next Steps

- Try both containers locally: [Development Guide](./development.md)
- Understand the application: [Application Guide](./application.md)
- Deploy to cloud: Check branch-specific tutorials
  - [GCloud Branch](../../tree/gcloud)
  - [Azure Branch](../../tree/azure)
