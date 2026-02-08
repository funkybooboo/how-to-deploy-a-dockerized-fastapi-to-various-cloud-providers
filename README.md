# Deploy FastAPI to Azure Container Apps

Production-ready FastAPI application deployed to Azure Container Apps with automated CI/CD, comprehensive tutorials, and best practices.

[![Deploy to Azure](https://img.shields.io/badge/Azure-Deploy-blue?logo=microsoft-azure)](https://azure.microsoft.com/en-us/products/container-apps/)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.109+-green?logo=fastapi)](https://fastapi.tiangolo.com/)
[![Python](https://img.shields.io/badge/Python-3.12-blue?logo=python)](https://www.python.org/)

> **📚 General Documentation**: For application architecture, Docker guides, and local development, see the [docs/](./docs/) directory with 5 comprehensive guides covering FastAPI, Docker, development workflow, and API reference.

## 🚀 What You'll Build

A fully automated deployment pipeline that:
- ✅ Runs tests automatically on every push
- ✅ Builds Docker containers
- ✅ Deploys to Azure Container Apps
- ✅ Scales automatically based on demand
- ✅ Costs $0 when idle (with scale-to-zero)

## 📚 Complete Tutorial Series

Follow our comprehensive, beginner-friendly tutorials:

1. **[Overview](./docs/tutorials/01-overview.md)** - What you'll build and why
2. **[Prerequisites](./docs/tutorials/02-prerequisites.md)** - Required tools and accounts
3. **[Local Setup](./docs/tutorials/03-local-setup.md)** - Dev Container environment
4. **[Understanding FastAPI](./docs/tutorials/04-understanding-fastapi.md)** - Framework deep-dive
5. **[Manual Deployment](./docs/tutorials/05-manual-deployment.md)** - Step-by-step deployment to Azure
6. **[CI/CD Setup](./docs/tutorials/06-cicd-setup.md)** - Automate with GitHub Actions
7. **[Monitoring](./docs/tutorials/07-monitoring.md)** - Logs, metrics, and debugging in Azure
8. **[Cleanup](./docs/tutorials/08-cleanup.md)** - Remove resources safely

**Having issues?** Check [troubleshooting.md](./docs/tutorials/troubleshooting.md)

## ⚡ Quick Start

### Option 1: Deploy Immediately

```bash
# Clone repository
git clone <repo-url>
cd how-to-deploy-a-dockerized-fastapi-to-cloud-providers
git checkout azure

# Run setup
./scripts/setup-azure.sh

# Deploy
./scripts/deploy-manual.sh
```

**Time:** ~10 minutes

### Option 2: Learn by Following Tutorials

Start with [tutorials/01-overview.md](./docs/tutorials/01-overview.md) for a guided learning experience that explains concepts before implementation.

**Time:** ~3 hours (split across sessions)

## 🏗️ Architecture

```
┌─────────────┐      ┌──────────────┐      ┌───────────────────┐
│   GitHub    │─────▶│GitHub Actions│─────▶│  Azure Container  │
│ Repository  │      │   (CI/CD)    │      │     Registry      │
└─────────────┘      └──────────────┘      └───────────────────┘
                                                       │
                                                       ▼
┌─────────────┐                           ┌───────────────────┐
│   Users     │◀──────────────────────────│   Azure Container │
│             │    HTTPS (auto-cert)      │        Apps       │
└─────────────┘                           └───────────────────┘
```

**Components:**
- **FastAPI** - Modern Python web framework with automatic API docs
- **Docker** - Containerization for consistent deployments
- **Azure Container Registry** - Private container image storage
- **Azure Container Apps** - Serverless container hosting with auto-scaling
- **GitHub Actions** - Automated testing and deployment

## 📁 Project Structure

```
├── src/
│   ├── main.py              # FastAPI application entry point
│   ├── config.py            # Environment-based configuration
│   ├── api/                 # API endpoint modules
│   │   ├── health.py        # Health check endpoints
│   │   └── hello.py         # Example endpoints
│   └── tests/               # Test suite
│       └── test_api.py      # API endpoint tests
├── docs/
│   └── tutorials/           # Complete tutorial series (01-08)
├── scripts/
│   ├── setup-azure.sh      # Initial Azure setup
│   ├── deploy-manual.sh     # Manual deployment script
│   └── cleanup.sh           # Resource cleanup script
├── .github/
│   └── workflows/
│       └── cicd.yaml        # CI/CD workflow for Azure
├── Dockerfile.dev           # Development container
├── Dockerfile.prod          # Production container
├── requirements.txt         # Python dependencies
└── requirements-dev.txt     # Development dependencies
```

## 🎯 Features

### Security
- ✅ Conditional debugging (only in development)
- ✅ Environment-based CORS configuration
- ✅ Managed identities for secure access
- ✅ No secrets in code (environment variables only)

### Code Quality
- ✅ Linting with Ruff
- ✅ Formatting with Black
- ✅ Type checking with MyPy
- ✅ Test coverage with pytest
- ✅ Comprehensive docstrings

### Production Ready
- ✅ Automatic API documentation (Swagger & ReDoc)
- ✅ Health check endpoints
- ✅ Structured logging
- ✅ Error tracking with Azure Monitor
- ✅ Resource limits and auto-scaling
- ✅ Zero-downtime deployments

### Developer Experience
- ✅ VS Code Dev Container
- ✅ Hot reload during development
- ✅ Pre-configured debugging
- ✅ Automated testing in CI/CD
- ✅ Helper scripts for common tasks

## 💰 Cost Estimate

Azure Container Apps offers a generous free tier:

**Free Tier (per month):**
- 180,000 vCPU-seconds
- 360,000 GiB-seconds of memory
- 2 million requests

**Beyond Free Tier:**
- Pricing is based on vCPU and memory allocation per second.
- Costs are generally low for small to medium applications, especially with scale-to-zero.

**Cost optimization:**
- Scales to zero when idle (default)
- Pay only for resources consumed during execution
- No charges for idle resources when scaled to zero

## 🛠️ Development

### Local Development

```bash
# Open in VS Code
code .

# Reopen in Container (F1 → "Dev Containers: Reopen in Container")

# Start development server (auto-reload enabled)
uvicorn src.main:app --host 0.0.0.0 --port 8080 --reload
```

**Access:**
- API: http://localhost:8080/
- Docs: http://localhost:8080/api/docs
- ReDoc: http://localhost:8080/api/redoc

### Run Tests

```bash
# Run all tests
pytest src/tests/ -v

# Run with coverage
pytest src/tests/ -v --cov=src --cov-report=term-missing

# Run linting
ruff check src/

# Run type checking
mypy src/

# Format code
black src/
```

### Manual Deployment

```bash
# Setup (first time only)
./scripts/setup-azure.sh

# Build and deploy
./scripts/deploy-manual.sh

# Or specify version tag
./scripts/deploy-manual.sh v2
```

### View Logs

```bash
# Stream logs
az containerapp logs stream --name fastapi-app --resource-group fastapi-rg

# View recent logs
az monitor log-analytics query --workspace <LOG_ANALYTICS_WORKSPACE_ID> --analytics-query "ContainerAppConsoleLogs_CL | where ContainerAppName_s == 'fastapi-app' | project TimeGenerated, Log_s | order by TimeGenerated desc"
```

## 🔒 CI/CD Setup

### Required GitHub Secrets

1. Go to Repository → Settings → Secrets → Actions
2. Add these secrets:
   - `AZURE_CREDENTIALS`: A JSON object with credentials for a service principal.

**See [06-cicd-setup.md](./docs/tutorials/06-cicd-setup.md) for detailed instructions.**

### Workflow Triggers

- **Push to `azure` branch**: Runs tests → Builds → Deploys
- **Pull Request**: Runs tests only (no deployment)
- **Manual**: GitHub Actions → "Run workflow"

## 📊 Monitoring

**Azure Portal:**
- Metrics: Navigate to your Container App -> Metrics
- Logs: Navigate to your Container App -> Log stream or Log Analytics
- Alerts: Set up alerts based on metrics or log queries

**CLI:**
```bash
# Query metrics
az monitor metrics list --resource <CONTAINER_APP_ID> --metric "Requests"
```

## 🧹 Cleanup

To remove all resources and avoid charges:

```bash
./scripts/cleanup.sh
```

Or manually:
```bash
# Delete resource group
az group delete --name fastapi-rg --yes --no-wait
```

## 🌐 Other Cloud Providers

This repository supports multiple cloud providers:

- **[Main Branch](../../tree/main)** - Cloud-agnostic base code
- **[Azure Branch](../../tree/azure)** - Azure Container Apps (you are here)
- **[GCloud Branch](../../tree/gcloud)** - Google Cloud Run

## 🤝 Contributing

Contributions welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

See [CONTRIBUTING.md](./CONTRIBUTING.md) for guidelines.

## 📝 License

This project is licensed under the MIT License - see LICENSE file for details.

## ⭐ Support

If you find this helpful:
- ⭐ Star this repository
- 🐛 Report issues
- 💡 Suggest improvements
- 📢 Share with others
