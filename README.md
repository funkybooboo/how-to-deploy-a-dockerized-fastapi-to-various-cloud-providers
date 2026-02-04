# FastAPI Multi-Cloud Deployment Template

Production-ready FastAPI application template with comprehensive documentation and deployment guides for multiple cloud platforms.

[![CI](https://img.shields.io/badge/CI-passing-brightgreen)](./.github/workflows/ci.yaml)
[![Python](https://img.shields.io/badge/Python-3.12-blue?logo=python)](https://www.python.org/)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.110+-green?logo=fastapi)](https://fastapi.tiangolo.com/)
[![Docker](https://img.shields.io/badge/Docker-ready-2496ED?logo=docker)](https://www.docker.com/)

## 📚 Complete Documentation

- **[Getting Started](./docs/getting-started.md)** - Get up and running in 5 minutes
- **[Application Guide](./docs/application.md)** - Understand the codebase and architecture
- **[Development Guide](./docs/development.md)** - Docker Compose, volume mounts, live reload
- **[Docker Guide](./docs/docker.md)** - Deep dive into Docker containerization
- **[API Reference](./docs/api-reference.md)** - Complete API endpoint documentation

## ⚡ Quick Start

### Option 1: Docker Compose (Recommended)

```bash
# Clone the repository
git clone <your-repo-url>
cd how-to-deploy-a-dockerized-fastapi-to-cloud-providers

# Start development server with live reload
docker-compose -f docker-compose.dev.yaml up

# Access the application
open http://localhost:8080            # API
open http://localhost:8080/api/docs   # Interactive docs
```

**Features:**
- ✅ Live code reload (edit files, see changes instantly)
- ✅ No rebuild needed
- ✅ All dependencies included
- ✅ Consistent environment

### Option 2: Local Python

```bash
# Create virtual environment
python -m venv venv
source venv/bin/activate  # or `venv\Scripts\activate` on Windows

# Install dependencies
pip install -r requirements.txt

# Run the application
python -m src.main

# Or with auto-reload
uvicorn src.main:app --reload --port 8080
```

See [Getting Started Guide](./docs/getting-started.md) for detailed instructions and troubleshooting.

## 🌟 What You'll Learn

This template demonstrates:

### Development Best Practices
- ✅ Clean code structure with modular routers
- ✅ Environment-based configuration
- ✅ Type hints and Pydantic models
- ✅ Comprehensive testing with pytest
- ✅ Code quality tools (ruff, black, mypy)
- ✅ Pre-configured VS Code Dev Container

### Docker & Containerization
- ✅ Development container with live reload
- ✅ Production-optimized container (164MB)
- ✅ Docker Compose for easy development
- ✅ Volume mounts for instant code updates
- ✅ Multi-stage builds (optional)

### Security
- ✅ Conditional debugging (not in production)
- ✅ Environment-based CORS configuration
- ✅ No secrets in code
- ✅ Production-ready settings

### Cloud Deployment
- ✅ Google Cloud Run (see gcloud branch)
- ✅ Azure Container Apps (see azure branch)
- ✅ CI/CD with GitHub Actions
- ✅ Automated testing and deployment

## 📖 Documentation Structure

### For Beginners

Start here if you're new to FastAPI or Docker:

1. **[Getting Started](./docs/getting-started.md)**
   - Install prerequisites (Docker, Git, Python)
   - Run your first container
   - Test the API
   - Make your first code change

2. **[Application Guide](./docs/application.md)**
   - Understand the code structure
   - Learn how FastAPI works
   - Explore configuration management
   - See examples of common patterns

3. **[API Reference](./docs/api-reference.md)**
   - Complete endpoint documentation
   - Request/response examples
   - Testing with curl, Python, JavaScript
   - Interactive Swagger UI

### For Developers

Advanced topics for production development:

4. **[Development Guide](./docs/development.md)**
   - Docker Compose workflow
   - Volume mounts for live reload
   - Debugging with VS Code
   - Running tests
   - Common development patterns

5. **[Docker Guide](./docs/docker.md)**
   - Dockerfile layer-by-layer explanation
   - Dev vs Prod containers
   - Docker commands cheat sheet
   - Multi-stage builds
   - Security best practices

### For Deployers

Ready to deploy to the cloud?

6. **Cloud Deployment Tutorials** (branch-specific)
   - **[Google Cloud Run (gcloud branch)](../../tree/gcloud)** - 8 comprehensive tutorials
   - **[Azure Container Apps (azure branch)](../../tree/azure)** - Complete deployment guide

## 🏗️ Project Structure

```
├── src/                        # Application source code
│   ├── main.py                 # FastAPI app entry point
│   ├── config.py               # Environment configuration
│   ├── api/                    # API endpoints (modular routers)
│   │   ├── health.py           # Health check endpoint
│   │   └── hello.py            # Example endpoints
│   └── tests/                  # Test suite (91% coverage)
│       └── test_api.py
├── docs/                       # 📚 Comprehensive documentation
│   ├── getting-started.md      # Quick start guide
│   ├── application.md          # Code structure & patterns
│   ├── development.md          # Dev workflow & tools
│   ├── docker.md               # Docker deep dive
│   └── api-reference.md        # Complete API docs
├── .github/workflows/
│   └── ci.yaml                 # Automated testing
├── Dockerfile.dev              # Development container
├── Dockerfile.prod             # Production container (164MB)
├── docker-compose.dev.yaml     # Dev with live reload
├── docker-compose.yaml         # Production-like local
├── requirements.txt            # Python dependencies
├── requirements-dev.txt        # Dev tools (pytest, ruff, etc.)
├── pyproject.toml              # Tool configurations
└── .env.example                # Environment template
```

## 🚀 Features

### API Features
- ✅ RESTful API with FastAPI
- ✅ Automatic interactive documentation (Swagger & ReDoc)
- ✅ Pydantic models for data validation
- ✅ Health check endpoint for monitoring
- ✅ CORS middleware with environment config
- ✅ Async/await support

### Development Features
- ✅ Hot reload (edit code, see changes instantly)
- ✅ Docker Compose for easy setup
- ✅ VS Code Dev Container included
- ✅ Comprehensive test suite (pytest)
- ✅ Linting (ruff), formatting (black), type checking (mypy)
- ✅ 91% test coverage

### Production Features
- ✅ Minimal Docker image (164MB)
- ✅ Environment-based configuration
- ✅ Security best practices
- ✅ CI/CD ready (GitHub Actions)
- ✅ Cloud-agnostic base code
- ✅ Logging and monitoring ready

## 🎯 API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/` | GET | Root health check |
| `/api/health` | GET | Detailed health status |
| `/api/hello` | GET | Hello World example |
| `/api/hello/{name}` | GET | Personalized greeting |
| `/api/docs` | GET | Swagger UI documentation |
| `/api/redoc` | GET | ReDoc documentation |

Try them:
```bash
curl http://localhost:8080/api/hello
curl http://localhost:8080/api/health
```

See [API Reference](./docs/api-reference.md) for complete documentation.

## 🧪 Testing

```bash
# Run all tests
pytest src/tests/

# Run with coverage
pytest src/tests/ --cov=src --cov-report=term-missing

# Run linting
ruff check src/

# Run type checking
mypy src/

# Format code
black src/
```

Current coverage: **91%**

## 🔧 Development Workflow

### Live Reload Development

```bash
# Start dev server
docker-compose -f docker-compose.dev.yaml up

# Edit files in ./src
# Save - uvicorn auto-reloads
# Test - no rebuild needed!
```

See [Development Guide](./docs/development.md) for details on:
- Volume mounts and how they work
- Debugging with VS Code
- Running tests
- When you need to rebuild

## 🌐 Multi-Cloud Support

This repository has three branches for different purposes:

### Main Branch (You Are Here)
- **Purpose**: Cloud-agnostic application code
- **What's Included**:
  - Complete FastAPI application
  - Docker development and production containers
  - Comprehensive documentation
  - Test suite and code quality tools
  - Local development setup
- **Use For**: Local development, understanding FastAPI, creating your own deployment

### GCloud Branch
- **Purpose**: Google Cloud Run deployment (Production Ready ✅)
- **What's Included**:
  - Everything from main branch
  - 8 comprehensive tutorials (~15,000 words)
  - Helper scripts (setup, deploy, cleanup)
  - Cloud Run configuration
  - GitHub Actions CI/CD
  - Troubleshooting guide
- **Deploy To**: Google Cloud Run
- **Documentation**: [GCloud Branch](../../tree/gcloud)

### Azure Branch
- **Purpose**: Azure Container Apps deployment
- **What's Included**:
  - Everything from main branch
  - Azure-specific tutorials
  - Azure Container Apps configuration
  - GitHub Actions CI/CD for Azure
- **Deploy To**: Azure Container Apps
- **Documentation**: [Azure Branch](../../tree/azure)

## 📋 Environment Variables

Configure the application via environment variables:

```bash
# Application
ENVIRONMENT=development          # development/production/testing
DEBUG=false                      # Enable debugging (development only!)
LOG_LEVEL=INFO                   # DEBUG/INFO/WARNING/ERROR

# API
API_PREFIX=/api                  # API route prefix
API_VERSION=1.0.0                # API version

# CORS (Security)
CORS_ORIGINS=*                   # development: *, production: specific domains

# Server
HOST=0.0.0.0                     # Listen address
PORT=8080                        # Port number
```

See [.env.example](./.env.example) for complete list.

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Run tests (`pytest src/tests/`)
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

See [CONTRIBUTING.md](./CONTRIBUTING.md) for detailed guidelines.

## 🙏 Credits

This project is based on the tutorial by Thaddeus Thomas:
- **Video Tutorial**: [How to Deploy a Dockerized FastAPI to Google Cloud Run](https://www.youtube.com/watch?v=DQwAX5pS4E8)
- **Original Repository**: [thaddavis/how-to-deploy-a-dockerized-fastapi-to-google-cloud-run](https://github.com/thaddavis/how-to-deploy-a-dockerized-fastapi-to-google-cloud-run/tree/main)

## 📝 License

This project is licensed under the GPL-3.0 License - see the [LICENSE](LICENSE) file for details.

## 📚 Learn More

### FastAPI
- [Official Documentation](https://fastapi.tiangolo.com/)
- [Python Type Hints](https://docs.python.org/3/library/typing.html)
- [Pydantic](https://docs.pydantic.dev/)

### Docker
- [Get Started with Docker](https://docs.docker.com/get-started/)
- [Docker Compose](https://docs.docker.com/compose/)
- [Best Practices](https://docs.docker.com/develop/dev-best-practices/)

### Cloud Platforms
- [Google Cloud Run](https://cloud.google.com/run/docs)
- [Azure Container Apps](https://docs.microsoft.com/en-us/azure/container-apps/)

## ⭐ Support

If you find this helpful:
- ⭐ Star this repository
- 🐛 [Report issues](https://github.com/your-repo/issues)
- 💡 [Suggest improvements](https://github.com/your-repo/issues/new)
- 📢 Share with others

---

**Ready to start?** → [Getting Started Guide](./docs/getting-started.md)

**Need help?** → Check the [documentation](./docs/) or open an issue

**Want to deploy?** → See the [gcloud](../../tree/gcloud) or [azure](../../tree/azure) branches
