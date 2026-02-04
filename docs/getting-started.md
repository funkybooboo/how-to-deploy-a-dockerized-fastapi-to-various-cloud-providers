# Getting Started

This guide will help you get the FastAPI application running on your local machine in minutes.

## Prerequisites

Before you begin, make sure you have these tools installed:

### Required Tools

**Docker Desktop**
- Download: https://www.docker.com/products/docker-desktop/
- Verify installation: `docker --version` and `docker-compose --version`
- Why: Runs the application in containers for consistent environments

**Git**
- Download: https://git-scm.com/downloads
- Verify installation: `git --version`
- Why: Clone the repository and manage code

### Optional Tools

**Python 3.12** (only if running without Docker)
- Download: https://www.python.org/downloads/
- Verify installation: `python --version`

**VS Code** (recommended IDE)
- Download: https://code.visualstudio.com/
- Extensions:
  - Python
  - Docker
  - Dev Containers (for container-based development)

## Quick Start - Three Ways to Run

### Option 1: Docker Compose (Recommended for Development)

```bash
# Clone the repository
git clone <your-repo-url>
cd how-to-deploy-a-dockerized-fastapi-to-cloud-providers

# Start development server with live reload
docker-compose -f docker-compose.dev.yaml up

# Access the application
open http://localhost:8080
open http://localhost:8080/api/docs  # Swagger UI
```

**What happens:**
- Builds a Docker container with all dependencies
- Mounts your code for live editing (no rebuild needed!)
- Starts FastAPI with auto-reload enabled
- Exposes the API on port 8080

### Option 2: Docker Without Compose

```bash
# Build development container
docker build -f Dockerfile.dev -t fastapi-dev .

# Run with volume mount for live editing
docker run -d \
  -p 8080:8080 \
  -v $(pwd)/src:/code/src \
  -e DEBUG=true \
  --name fastapi-dev \
  fastapi-dev

# Access the application
open http://localhost:8080
```

### Option 3: Without Docker (Local Python)

```bash
# Create virtual environment
python -m venv venv

# Activate virtual environment
source venv/bin/activate  # Linux/Mac
# OR
venv\Scripts\activate     # Windows

# Install dependencies
pip install -r requirements.txt

# Run the application
python -m src.main

# Or use uvicorn directly with auto-reload
uvicorn src.main:app --reload --port 8080
```

## Verify It's Working

### Test the API

```bash
# Root endpoint
curl http://localhost:8080/

# Health check
curl http://localhost:8080/api/health

# Hello endpoint
curl http://localhost:8080/api/hello

# Hello with name
curl http://localhost:8080/api/hello/YourName
```

### Expected Responses

**Root endpoint:**
```json
{
  "message": "OK 🚀",
  "version": "1.0.0",
  "environment": "development"
}
```

**Health check:**
```json
{
  "status": "healthy",
  "message": "OK"
}
```

**Hello endpoint:**
```json
{
  "message": "Hello, World!"
}
```

### Interactive API Documentation

Open your browser to:
- **Swagger UI**: http://localhost:8080/api/docs
- **ReDoc**: http://localhost:8080/api/redoc

Try out the API directly from your browser!

## Making Changes

### With Docker (Recommended)

1. Edit files in `./src` with your favorite editor
2. Save the file
3. Watch the logs - uvicorn will automatically reload
4. Refresh your browser or re-run curl commands
5. **No rebuild needed!**

Example:
```bash
# Edit a file
vim src/api/hello.py

# Watch the logs (in another terminal)
docker-compose -f docker-compose.dev.yaml logs -f

# You'll see:
# INFO:     Shutting down
# WARNING:  StatReload detected changes in 'src/api/hello.py'. Reloading...
# INFO:     Started server process [21]
```

### Without Docker

1. Make sure you started with `--reload` flag
2. Edit files
3. Save - uvicorn will automatically reload

## Environment Variables

Configure the application by setting environment variables:

```bash
# Development
export DEBUG=true
export ENVIRONMENT=development
export CORS_ORIGINS=*
export LOG_LEVEL=DEBUG

# Production
export DEBUG=false
export ENVIRONMENT=production
export CORS_ORIGINS=https://your-domain.com
export LOG_LEVEL=INFO
```

See [.env.example](../.env.example) for all available options.

## Stopping the Application

### Docker Compose
```bash
# Stop (keeps containers)
docker-compose -f docker-compose.dev.yaml stop

# Stop and remove (clean slate)
docker-compose -f docker-compose.dev.yaml down
```

### Docker
```bash
docker stop fastapi-dev
docker rm fastapi-dev
```

### Local Python
```bash
# Press Ctrl+C in the terminal where uvicorn is running
```

## Troubleshooting

### Port 8080 Already in Use

```bash
# Find what's using the port
lsof -i :8080  # Linux/Mac
netstat -ano | findstr :8080  # Windows

# Kill the process or change the port
# For Docker Compose, edit docker-compose.dev.yaml:
#   ports:
#     - "8081:8080"  # Use 8081 on host
```

### Container Won't Start

```bash
# Check Docker is running
docker info

# View container logs
docker-compose -f docker-compose.dev.yaml logs

# Rebuild from scratch
docker-compose -f docker-compose.dev.yaml up --build
```

### Permission Issues (Linux)

```bash
# Fix ownership
sudo chown -R $USER:$USER ./src
```

### Module Not Found Error

Without Docker:
```bash
# Make sure PYTHONPATH is set
export PYTHONPATH=.

# Or run as module
python -m src.main
```

## Next Steps

Now that you have the application running:

1. **Explore the Code** - See [Application Guide](./application.md)
2. **Learn Development Workflow** - See [Development Guide](./development.md)
3. **Understand Docker** - See [Docker Guide](./docker.md)
4. **Deploy to Cloud** - Check out branch-specific tutorials:
   - [GCloud Branch](../../tree/gcloud) - Google Cloud Run
   - [Azure Branch](../../tree/azure) - Azure Container Apps

## Need Help?

- Check the [API Reference](./api-reference.md)
- Review [Docker Guide](./docker.md)
- See [development.md](./development.md) for development tips
- Open an issue on GitHub
