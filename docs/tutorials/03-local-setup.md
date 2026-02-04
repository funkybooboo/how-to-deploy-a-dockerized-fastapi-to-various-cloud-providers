# Local Setup: Development Environment

This tutorial walks you through setting up your local development environment using VS Code Dev Containers.

## What is a Dev Container?

A **Dev Container** is a Docker container configured specifically for development. It provides:

- **Consistent Environment**: Everyone on the team uses the exact same tools and versions
- **Pre-configured**: All dependencies and tools installed automatically
- **Isolated**: Doesn't interfere with your local machine setup
- **Reproducible**: Works the same way on macOS, Windows, and Linux

Think of it as a pre-packaged development environment that "just works."

## Understanding the Dev Container Configuration

Our project includes a `.devcontainer/` folder with these files:

### `devcontainer.json`
Tells VS Code how to set up the development container:
- Which Dockerfile to use
- Which VS Code extensions to install
- Port forwarding configuration
- Environment variables

### `Dockerfile.dev`
Defines what's inside the development container:
- Python 3.12
- Google Cloud CLI
- Essential development tools
- All Python dependencies from requirements.txt

## Starting the Dev Container

### Step 1: Open Project in VS Code

```bash
# Navigate to the project directory
cd how-to-deploy-a-dockerized-fastapi-to-various-cloud-providers

# Make sure you're on the gcloud branch
git checkout gcloud

# Open in VS Code
code .
```

### Step 2: Reopen in Container

When VS Code opens, you should see a popup:

```
Folder contains a Dev Container configuration file.
Reopen in Container
```

Click **"Reopen in Container"**.

**Alternative:** If you don't see the popup:
1. Press `F1` or `Ctrl+Shift+P` (Windows/Linux) / `Cmd+Shift+P` (macOS)
2. Type "Dev Containers: Reopen in Container"
3. Press Enter

### Step 3: Wait for Container to Build

The first time, this takes 3-5 minutes:
- Downloads base Python image
- Installs Google Cloud SDK
- Installs Python dependencies
- Configures VS Code extensions

VS Code shows progress in the bottom-right corner. Subsequent starts are much faster (30 seconds).

### Step 4: Verify the Environment

Once the container is ready, open a new terminal in VS Code (`Ctrl+` ` or Terminal → New Terminal).

Run these verification commands:

```bash
# Check Python version
python --version
# Expected: Python 3.12.x

# Check gcloud is installed
gcloud --version
# Expected: Google Cloud SDK version info

# Check project structure
ls -la
# You should see: src/, docs/, scripts/, etc.

# Verify Python packages are installed
pip list | grep fastapi
# Expected: fastapi version listed
```

## Running the Application Locally

### Start the Development Server

```bash
# The uvicorn server runs with auto-reload enabled
# This means changes to code automatically restart the server
uvicorn src.main:app --host 0.0.0.0 --port 8080 --reload
```

**Expected Output:**
```
INFO:     Will watch for changes in these directories: ['/code']
INFO:     Uvicorn running on http://0.0.0.0:8080 (Press CTRL+C to quit)
INFO:     Started reloader process
INFO:     Started server process
INFO:     Waiting for application startup.
INFO:     Application startup complete.
```

### Access the Application

Open your browser and navigate to:

**Root Endpoint:**
```
http://localhost:8080/
```
Should show: `{"message": "OK 🚀", "version": "1.0.0", "environment": "development"}`

**API Documentation (Swagger UI):**
```
http://localhost:8080/api/docs
```
Interactive API documentation where you can test endpoints

**Alternative API Docs (ReDoc):**
```
http://localhost:8080/api/redoc
```
Alternative documentation style

### Test API Endpoints

**Using curl:**
```bash
# Health check
curl http://localhost:8080/api/health

# Hello endpoint
curl http://localhost:8080/api/hello

# Personalized greeting
curl http://localhost:8080/api/hello/World
```

**Using Swagger UI:**
1. Go to http://localhost:8080/api/docs
2. Click on `/api/hello` endpoint
3. Click "Try it out"
4. Click "Execute"
5. See the response

## Understanding the Code Structure

```
├── src/
│   ├── main.py          # FastAPI application entry point
│   ├── config.py        # Environment-based configuration
│   ├── api/             # API endpoint modules
│   │   ├── health.py    # Health check endpoints
│   │   └── hello.py     # Hello world endpoints
│   └── tests/           # Test suite
│       └── test_api.py  # API endpoint tests
├── Dockerfile.dev       # Development container definition
├── Dockerfile.prod      # Production container definition
├── requirements.txt     # Python dependencies
└── .devcontainer/       # VS Code Dev Container config
```

## Running Tests

Our project includes a test suite using pytest:

```bash
# Run all tests
pytest src/tests/ -v

# Run with coverage report
pytest src/tests/ -v --cov=src --cov-report=term-missing

# Run specific test file
pytest src/tests/test_api.py -v
```

**Expected Output:**
```
======================== test session starts ========================
collected 4 items

src/tests/test_api.py::test_root_endpoint PASSED
src/tests/test_api.py::test_health_endpoint PASSED
src/tests/test_api.py::test_hello_endpoint PASSED
src/tests/test_api.py::test_hello_name_endpoint PASSED

======================== 4 passed in 0.42s =========================
```

## Code Quality Tools

### Linting (Ruff)

Check code for errors and style issues:

```bash
# Check all Python files in src/
ruff check src/

# Fix auto-fixable issues
ruff check src/ --fix
```

### Formatting (Black)

Format code to consistent style:

```bash
# Check if code is formatted
black --check src/

# Format all files
black src/
```

### Type Checking (MyPy)

Check type annotations:

```bash
mypy src/
```

## Making Code Changes

### Try It: Add a New Endpoint

1. Open `src/api/hello.py`
2. Add this new endpoint:

```python
@router.get("/hello/goodbye/{name}", response_model=HelloResponse)
async def get_goodbye(name: str) -> HelloResponse:
    """Return a goodbye message."""
    return HelloResponse(message=f"Goodbye, {name}!")
```

3. Save the file
4. Notice the server automatically restarts (check terminal)
5. Test the new endpoint:

```bash
curl http://localhost:8080/api/hello/goodbye/World
# Should return: {"message": "Goodbye, World!"}
```

6. Check Swagger UI - the new endpoint appears automatically!

## Environment Variables

The application uses environment variables for configuration. These are set in `.env` files:

### View Current Configuration

```bash
# Inside the container
cat .env.example
```

### Create Local Environment File

```bash
# Copy example to create your local config
cp .env.example .env

# Edit values as needed
nano .env  # or use VS Code: code .env
```

**Important Environment Variables:**
- `ENVIRONMENT`: `development` or `production`
- `DEBUG`: `true` enables debugpy for debugging
- `CORS_ORIGINS`: Comma-separated list of allowed origins
- `PORT`: Port to run the server on (default: 8080)

## Debugging

The Dev Container includes debugpy for debugging. When `DEBUG=true`, the debugger listens on port 5678.

### VS Code Debugging

1. Set a breakpoint by clicking in the gutter next to a line number
2. Press `F5` or go to Run → Start Debugging
3. Choose "Python: Remote Attach"
4. The debugger connects and stops at your breakpoint

## Stopping the Dev Container

### Stop the Server

Press `Ctrl+C` in the terminal running uvicorn.

### Close the Dev Container

Two options:

**Option 1: Reopen Locally**
1. Press `F1`
2. Type "Dev Containers: Reopen Folder Locally"
3. Press Enter

**Option 2: Close VS Code**
- Just close VS Code
- The container stops automatically

## Common Issues

### Port Already in Use

**Problem:** `Error: Address already in use`

**Solution:**
```bash
# Find process using port 8080
lsof -i :8080  # macOS/Linux
netstat -ano | findstr :8080  # Windows

# Kill the process or use a different port
uvicorn src.main:app --host 0.0.0.0 --port 8081 --reload
```

### Dev Container Won't Start

**Problem:** "Error: Container failed to start"

**Solution:**
1. Ensure Docker Desktop is running
2. Check Docker has sufficient resources (4GB RAM minimum)
3. Rebuild container: F1 → "Dev Containers: Rebuild Container"

### Import Errors

**Problem:** `ModuleNotFoundError: No module named 'fastapi'`

**Solution:**
```bash
# Reinstall dependencies inside container
pip install -r requirements.txt
```

## Next Steps

Now that your local environment is set up and running:
1. ✅ Dev Container is running
2. ✅ Application runs locally
3. ✅ Tests pass
4. ✅ You can make changes and see them reload

Continue to [04-understanding-fastapi.md](./04-understanding-fastapi.md) to learn about the FastAPI framework and explore the codebase in depth.

---

**Need Help?**
- VS Code Dev Containers: [code.visualstudio.com/docs/devcontainers/containers](https://code.visualstudio.com/docs/devcontainers/containers)
- FastAPI documentation: [fastapi.tiangolo.com](https://fastapi.tiangolo.com/)
- Python debugging: [code.visualstudio.com/docs/python/debugging](https://code.visualstudio.com/docs/python/debugging)
