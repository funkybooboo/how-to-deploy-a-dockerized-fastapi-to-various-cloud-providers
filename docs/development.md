# Development Guide

## Quick Start with Docker Compose (Recommended)

### Development Mode with Live Reload

```bash
# Start development server with live code reloading
docker-compose -f docker-compose.dev.yaml up

# Or run in background
docker-compose -f docker-compose.dev.yaml up -d

# View logs
docker-compose -f docker-compose.dev.yaml logs -f

# Stop
docker-compose -f docker-compose.dev.yaml down
```

**How it works:**
- Your local `./src` directory is mounted into the container
- When you edit files, changes appear instantly
- Uvicorn detects changes and auto-reloads
- No rebuild needed!

### Production Mode

```bash
# Start production server
docker-compose up

# Or run in background
docker-compose up -d

# Stop
docker-compose down
```

## Manual Docker Commands

### Development (with volume mount)

```bash
# Build once
docker build -f Dockerfile.dev -t fastapi-dev .

# Run with volume mount for live editing
docker run -d \
  -p 8080:8080 \
  -v $(pwd)/src:/code/src \
  -e DEBUG=true \
  --name fastapi-dev \
  fastapi-dev

# View logs
docker logs -f fastapi-dev

# Stop and remove
docker stop fastapi-dev && docker rm fastapi-dev
```

### Production (no volume mount)

```bash
# Build
docker build -f Dockerfile.prod -t fastapi-prod .

# Run
docker run -d \
  -p 8080:8080 \
  -e DEBUG=false \
  -e ENVIRONMENT=production \
  --name fastapi-prod \
  fastapi-prod
```

## Understanding Volume Mounts

### What's Happening?

```yaml
volumes:
  - ./src:/code/src  # Local path : Container path
```

- **Left side** (`./src`): Your local directory on the host machine
- **Right side** (`/code/src`): Directory inside the container
- Files are "linked" - changes on either side reflect immediately

### When to Rebuild?

**You DON'T need to rebuild when:**
- ✅ Editing Python code in `./src`
- ✅ Adding new Python files
- ✅ Changing environment variables

**You DO need to rebuild when:**
- ❌ Changing `requirements.txt` (adding/removing packages)
- ❌ Modifying Dockerfile
- ❌ Installing system packages

To rebuild:
```bash
docker-compose -f docker-compose.dev.yaml up --build
```

## Testing Your Setup

### 1. Start the dev server
```bash
docker-compose -f docker-compose.dev.yaml up
```

### 2. Make a code change

Edit `src/api/hello.py` and change the message:

```python
@router.get("/hello")
async def get_hello() -> HelloResponse:
    return HelloResponse(message="Hello, Docker Volume Mounts!")
```

### 3. Watch the logs

You should see:
```
fastapi-dev | INFO:     Shutting down
fastapi-dev | INFO:     Waiting for application shutdown.
fastapi-dev | INFO:     Application shutdown complete.
fastapi-dev | INFO:     Finished server process [8]
fastapi-dev | WARNING:  StatReload detected changes in 'src/api/hello.py'. Reloading...
fastapi-dev | INFO:     Started server process [17]
fastapi-dev | INFO:     Waiting for application startup.
fastapi-dev | INFO:     Application startup complete.
```

### 4. Test the change

```bash
curl http://localhost:8080/api/hello
# Should return: {"message": "Hello, Docker Volume Mounts!"}
```

No rebuild needed! 🎉

## VS Code Dev Container

Alternatively, use VS Code's Dev Container feature:

1. Open project in VS Code
2. Press `F1` → "Dev Containers: Reopen in Container"
3. Code directly inside the container with full IDE support
4. Changes are automatically synced

Configuration: `.devcontainer/devcontainer.json`

## Common Issues

### Permission Issues (Linux)

If you see permission errors, you might need to fix ownership:

```bash
# Find the container's user ID
docker-compose -f docker-compose.dev.yaml exec fastapi-dev id

# Change ownership on host (if needed)
sudo chown -R $USER:$USER ./src
```

### Changes Not Detected

1. Check volume is mounted:
   ```bash
   docker-compose -f docker-compose.dev.yaml exec fastapi-dev ls -la /code/src
   ```

2. Check uvicorn is running with `--reload`:
   ```bash
   docker-compose -f docker-compose.dev.yaml exec fastapi-dev ps aux
   ```

3. Restart the container:
   ```bash
   docker-compose -f docker-compose.dev.yaml restart
   ```

### Container Won't Start

1. Check logs:
   ```bash
   docker-compose -f docker-compose.dev.yaml logs
   ```

2. Check port conflicts:
   ```bash
   lsof -i :8080  # Linux/Mac
   # If something is using port 8080, stop it or change the port
   ```

## Tips

- **Docker Compose** is easier than manual `docker run` commands
- **Volume mounts** enable fast development iteration
- **--reload flag** must be enabled for auto-reload to work
- **Dev Container** provides the best IDE integration experience
