# Multi-Cloud FastAPI Deployment Repository - Project Roadmap

## Project Vision

Transform this repository into a professional learning resource with production-ready cloud deployments. The repository supports both learning (via starter branches) and production reference (via complete branches), with clear tutorials that explain concepts before implementation.

## Branch Strategy

```
main (cloud-agnostic base)
├── Fixed security issues (conditional debugpy, configurable CORS)
├── Production-quality code (docstrings, type hints, tests)
└── Comprehensive .gitignore

├── gcloud (complete production solution)
│   ├── Production-ready CI/CD
│   ├── Comprehensive tutorials (conceptual + practical)
│   ├── Helper scripts (setup, deploy, cleanup)
│   └── Architecture diagrams
│
├── gcloud-starter (learning starting point)
│   ├── TODO markers in code/configs
│   ├── Guided exercises in tutorials
│   ├── Validation scripts
│   └── Reset script to start over
│
├── azure (complete production solution)
│   └── [Same structure as gcloud]
│
└── azure-starter (learning starting point)
    └── [Same structure as gcloud-starter]
```

## User Requirements & Decisions

### Initial Requirements
- Multi-cloud support (GCloud and Azure - AWS, DigitalOcean, and Linode deferred)
- Comprehensive, straightforward documentation without information overload
- Detailed and explained but not verbose or bloated
- Better file naming and organization
- Streamlined without losing important information
- Specify tools needed for tutorials
- **Working** CI/CD files that actually deploy
- Tutorials explain how workflows work for each cloud provider
- Repos should be deployment-ready but with instructions to build from scratch

### User Preferences (from Q&A)
- ✅ **GCloud Branch**: Start fresh with well-designed files (not restore from git history)
- ✅ **Learning Mode**: Create starter branches (`gcloud-starter`, `azure-starter`) as clean starting points
- ✅ **Tutorial Style**: Conceptual + Practical (explain why, show architecture, then implement)
- ✅ **CI/CD**: Production-ready with clear placeholders and .env.example files

---

## Phase 1: Fix Main Branch Foundation ✅ COMPLETED

### Overview
Establish a secure, well-tested, cloud-agnostic foundation that all other branches build upon.

### Security Fixes

- [x] Create `src/config.py` for environment configuration
  - [x] Settings class with environment variables
  - [x] ENVIRONMENT, DEBUG, CORS_ORIGINS, HOST, PORT, LOG_LEVEL, API_PREFIX
  - [x] `is_production` property
  - [x] `@lru_cache()` for singleton pattern
  - [x] Type hints on all properties

- [x] Update `src/main.py` with security fixes
  - [x] Conditional debugpy import (only when DEBUG=true)
  - [x] Environment-based CORS configuration
  - [x] Import and use settings from config.py
  - [x] Improved app metadata (title, description, version)
  - [x] Configurable docs URLs with API_PREFIX

### Code Quality Improvements

- [x] Rename `src/smokeTest/` to `src/api/`
  - [x] Move directory
  - [x] Update all imports in main.py

- [x] Create `src/api/__init__.py`
  - [x] Expose routers

- [x] Create `src/api/health.py`
  - [x] Dedicated health check endpoint
  - [x] Pydantic response model (HealthResponse)
  - [x] Proper docstrings
  - [x] Type hints

- [x] Create `src/api/hello.py`
  - [x] Rename `prompt()` function to `get_hello()`
  - [x] Add personalized greeting endpoint `get_hello_name(name: str)`
  - [x] Pydantic response model (HelloResponse)
  - [x] Proper docstrings
  - [x] Type hints

- [x] Delete old `src/smokeTest/router.py`

### Testing Infrastructure

- [x] Create `src/tests/__init__.py`

- [x] Create `src/tests/test_api.py`
  - [x] Test root endpoint
  - [x] Test health endpoint
  - [x] Test hello endpoint
  - [x] Test personalized hello endpoint
  - [x] Use TestClient from FastAPI
  - [x] Set testing environment variables

- [x] Create `requirements-dev.txt`
  - [x] pytest>=8.0.0
  - [x] pytest-cov>=4.1.0
  - [x] pytest-asyncio>=0.23.0
  - [x] httpx>=0.26.0
  - [x] ruff>=0.1.0
  - [x] black>=24.0.0
  - [x] isort>=5.13.0
  - [x] mypy>=1.8.0
  - [x] types-python-dateutil

- [x] Create `pyproject.toml` with tool configurations
  - [x] black configuration (line-length: 100, target: py312)
  - [x] ruff configuration (select rules, ignore list, per-file ignores)
  - [x] pytest configuration (testpaths, naming patterns, coverage)
  - [x] mypy configuration (strict settings, test overrides)
  - [x] coverage configuration (source, omit, exclude_lines)

### Environment & Deployment Config

- [x] Expand `.gitignore`
  - [x] Python artifacts (__pycache__, *.pyc, etc.)
  - [x] Virtual environments (venv/, env/)
  - [x] IDE files (.vscode/, .idea/)
  - [x] Environment files (.env, .env.local, .env.*.local)
  - [x] Testing artifacts (.pytest_cache/, .coverage, htmlcov/)
  - [x] Type checking cache (.mypy_cache/)
  - [x] Linting cache (.ruff_cache/)
  - [x] Jupyter checkpoints
  - [x] Cloud credentials (key.json, *-credentials.json, service-account*.json)
  - [x] Logs (*.log, logs/)
  - [x] OS files (.DS_Store, Thumbs.db)
  - [x] Build artifacts (*.whl)

- [x] Create `.env.example`
  - [x] Application settings (ENVIRONMENT, DEBUG, LOG_LEVEL)
  - [x] API configuration (CORS_ORIGINS, API_PREFIX, API_VERSION)
  - [x] Server configuration (HOST, PORT)
  - [x] Comments explaining each variable

### GitHub Actions for Main Branch

- [x] Create `.github/workflows/test.yaml`
  - [x] Trigger on push/PR to main branch
  - [x] Set up Python 3.12 with pip caching
  - [x] Install requirements.txt and requirements-dev.txt
  - [x] Run ruff linting
  - [x] Run mypy type checking (continue-on-error: true)
  - [x] Run pytest with coverage
  - [x] Run black formatting check (continue-on-error: true)

### Commit and Push

- [x] Commit all Phase 1 changes with detailed message
- [x] Push to main branch
- [x] Verify tests pass in GitHub Actions

---

## Phase 2: Build GCloud Complete Branch ✅ COMPLETED

### Overview
Create production-ready Google Cloud Run deployment with comprehensive tutorials, automation scripts, and CI/CD pipeline.

### Branch Setup

- [x] Create `gcloud` branch from main
- [x] Merge Phase 1 improvements from main

### Development Environment

- [x] Update `Dockerfile.dev` (gcloud branch only)
  - [x] Add Google Cloud SDK installation
  - [x] Configure apt repository for gcloud
  - [x] Install google-cloud-cli package
  - [x] Keep all existing development tools

### Cloud Configuration Files

- [x] Create `config/` directory

- [x] Create `config/cloudrun-service.yaml`
  - [x] apiVersion: serving.knative.dev/v1
  - [x] Service metadata (name, annotations)
  - [x] Auto-scaling configuration (minScale: 0, maxScale: 10)
  - [x] Container configuration (image, port, env vars)
  - [x] Resource limits (cpu: 1, memory: 512Mi)
  - [x] Concurrency: 80
  - [x] Timeout: 300 seconds
  - [x] Comments explaining each setting

- [x] Create `.gcloudignore`
  - [x] Git files (.git, .github, .gitignore)
  - [x] IDE files
  - [x] Environment files (exclude .env but include .env.example)
  - [x] Python artifacts
  - [x] Documentation (docs/, *.md except README.md)
  - [x] Scripts directory
  - [x] Dev container files
  - [x] Test files

### Helper Scripts

- [x] Create `scripts/` directory

- [x] Create `scripts/setup-gcloud.sh` (executable)
  - [x] Color output variables (GREEN, RED, YELLOW, BLUE, NC)
  - [x] Check if gcloud CLI is installed
  - [x] Get or prompt for project ID
  - [x] Set gcloud project
  - [x] Enable required APIs:
    - [x] run.googleapis.com
    - [x] artifactregistry.googleapis.com
    - [x] cloudbuild.googleapis.com
  - [x] Prompt for region (default: us-central1)
  - [x] Create Artifact Registry repository
  - [x] Configure Docker authentication
  - [x] Save configuration to .gcloud-config file
  - [x] Display next steps
  - [x] Error handling and validation
  - [x] Comprehensive comments

- [x] Create `scripts/deploy-manual.sh` (executable)
  - [x] Load configuration from .gcloud-config
  - [x] Support version tag parameter (default: latest)
  - [x] Display configuration summary
  - [x] Check if Docker is running
  - [x] Build Docker image with versioned tags
  - [x] Tag as both SHA and latest
  - [x] Push to Artifact Registry
  - [x] Deploy to Cloud Run with full configuration
  - [x] Get service URL
  - [x] Test deployment with curl
  - [x] Display service endpoints
  - [x] Error handling and status messages
  - [x] Comprehensive comments

- [x] Create `scripts/cleanup.sh` (executable)
  - [x] Load configuration from .gcloud-config
  - [x] Display warning about resource deletion
  - [x] Require explicit "yes" confirmation
  - [x] Delete Cloud Run service
  - [x] Delete Artifact Registry repository
  - [x] Remove local .gcloud-config file
  - [x] Verify deletions
  - [x] Display cleanup summary
  - [x] Error handling for missing resources
  - [x] Comprehensive comments

- [x] Make all scripts executable (chmod +x)

### Production CI/CD Workflow

- [x] Create `.github/workflows/deploy.yaml`
  - [x] Name: "Deploy to Google Cloud Run"
  - [x] Environment variables (PROJECT_ID, REGION, SERVICE_NAME, etc.)
  - [x] Trigger on push to gcloud branch
  - [x] Ignore paths (docs/**, scripts/**, *.md, .gcloudignore)
  - [x] Support workflow_dispatch for manual triggering

- [x] Test Job
  - [x] Run on ubuntu-latest
  - [x] Checkout code
  - [x] Set up Python 3.12 with pip caching
  - [x] Install requirements.txt and requirements-dev.txt
  - [x] Run ruff linting
  - [x] Run mypy type checking (continue-on-error)
  - [x] Run pytest with coverage
  - [x] Run black formatting check (continue-on-error)

- [x] Deploy Job
  - [x] Needs: test (only deploy if tests pass)
  - [x] Run on ubuntu-latest
  - [x] Only on push (not PR)
  - [x] Permissions: contents: read, id-token: write
  - [x] Authenticate to Google Cloud (google-github-actions/auth@v2)
  - [x] Set up Cloud SDK
  - [x] Configure Docker for Artifact Registry
  - [x] Build Docker image (tag with SHA and latest)
  - [x] Push Docker image (both tags)
  - [x] Deploy to Cloud Run with full configuration:
    - [x] Image with SHA tag
    - [x] Region, platform, authentication
    - [x] Port, CPU, memory
    - [x] Min/max instances, concurrency, timeout
    - [x] Environment variables (ENVIRONMENT=production, DEBUG=false, LOG_LEVEL=INFO)
  - [x] Get service URL
  - [x] Verify deployment (curl with sleep)
  - [x] Display deployment summary

### Comprehensive Tutorial Series

- [x] Create `docs/tutorials/` directory

- [x] Create `docs/tutorials/01-overview.md`
  - [x] What You'll Build section
  - [x] Architecture diagram
  - [x] What is Cloud Run? (concepts, features)
  - [x] Learning outcomes
  - [x] Prerequisites list
  - [x] Time estimates (per section and total)
  - [x] Cost estimates (free tier, beyond free tier, examples)
  - [x] Tutorial structure breakdown
  - [x] What's different about this tutorial
  - [x] Link to next tutorial

- [x] Create `docs/tutorials/02-prerequisites.md`
  - [x] Required Tools section:
    - [x] Git (install instructions for all OS, verify command)
    - [x] Docker Desktop (install links, verify commands)
    - [x] VS Code (install link, required extensions)
    - [x] Google Cloud CLI (install options, verify command)
  - [x] Required Accounts section:
    - [x] Google Cloud account setup
    - [x] Project creation instructions
    - [x] GitHub account setup
    - [x] Repository fork/clone instructions
  - [x] Verification checklist
  - [x] Common issues and solutions
  - [x] Link to next tutorial

- [x] Create `docs/tutorials/03-local-setup.md`
  - [x] What is a Dev Container? (explanation, benefits)
  - [x] Understanding dev container configuration
  - [x] Step-by-step container startup
  - [x] Verify environment commands
  - [x] Running the application locally
  - [x] Access endpoints (root, docs, redoc)
  - [x] Test API endpoints (curl examples, Swagger UI)
  - [x] Understanding code structure
  - [x] Running tests (all tests, with coverage, specific tests)
  - [x] Code quality tools (linting, formatting, type checking)
  - [x] Making code changes (hands-on exercise)
  - [x] Environment variables section
  - [x] Debugging setup
  - [x] Stopping the dev container
  - [x] Common issues and solutions
  - [x] Link to next tutorial

- [x] Create `docs/tutorials/04-understanding-fastapi.md`
  - [x] What is FastAPI? (features, comparison table)
  - [x] Core concepts:
    - [x] ASGI Application
    - [x] Route decorators
    - [x] Path parameters
    - [x] Pydantic models
    - [x] Dependency injection
  - [x] Code walkthrough:
    - [x] src/config.py breakdown
    - [x] src/main.py section by section
    - [x] src/api/health.py explanation
    - [x] src/api/hello.py explanation
  - [x] Request/response flow diagram
  - [x] Async vs sync functions
  - [x] Automatic API documentation (Swagger UI, ReDoc)
  - [x] Hands-on exercise (add farewell endpoint)
  - [x] Key takeaways
  - [x] Link to next tutorial

- [x] Create `docs/tutorials/05-manual-deployment.md`
  - [x] Understanding Cloud Run (concepts, how it works, vs traditional)
  - [x] Cold starts explanation
  - [x] Understanding components:
    - [x] Artifact Registry
    - [x] Service Account
    - [x] Container Image
  - [x] Prerequisites check
  - [x] Step-by-step deployment:
    - [x] Step 1: Authenticate with gcloud
    - [x] Step 2: Set your project
    - [x] Step 3: Run setup script (detailed explanation)
    - [x] Step 4: Build Docker image
    - [x] Step 5: Test image locally
    - [x] Step 6: Push to Artifact Registry
    - [x] Step 7: Deploy to Cloud Run (parameter explanations)
    - [x] Step 8: Test deployment
  - [x] Understanding what happened (lifecycle, revisions, URLs)
  - [x] Managing environment variables
  - [x] Updating deployment
  - [x] Viewing logs
  - [x] Cost monitoring
  - [x] Troubleshooting section
  - [x] Security best practices
  - [x] Link to next tutorial

- [x] Create `docs/tutorials/06-cicd-setup.md`
  - [x] What is CI/CD? (definition, benefits, our pipeline)
  - [x] Understanding GitHub Actions (concepts)
  - [x] Understanding our workflow:
    - [x] Workflow name and triggers
    - [x] Environment variables
    - [x] Test job breakdown
    - [x] Deploy job breakdown
    - [x] Authentication step
    - [x] Build and push steps
    - [x] Deploy step
    - [x] Verification steps
  - [x] Setting up GitHub secrets:
    - [x] Create service account
    - [x] Grant permissions
    - [x] Generate key
    - [x] Add to GitHub
    - [x] Clean up key file
  - [x] Triggering the workflow (automatic and manual)
  - [x] Monitoring the workflow
  - [x] Understanding build failures
  - [x] Workflow best practices
  - [x] Cost considerations
  - [x] Security best practices
  - [x] Troubleshooting section
  - [x] Link to next tutorial

- [x] Create `docs/tutorials/07-monitoring.md`
  - [x] Why monitoring matters
  - [x] Cloud Run metrics:
    - [x] Request count
    - [x] Request latency (P50, P95, P99)
    - [x] Container instance count
    - [x] Billable time
    - [x] Error rate
  - [x] Cloud Logging:
    - [x] View logs (console and CLI)
    - [x] Log types (request, application, system)
    - [x] Log filtering (severity, time, HTTP status)
    - [x] Structured logging
  - [x] Error tracking (Cloud Error Reporting)
  - [x] Common errors and solutions
  - [x] Performance monitoring
  - [x] Alerting (create policies, best practices)
  - [x] Debugging production issues (step-by-step)
  - [x] Cost monitoring
  - [x] Uptime monitoring
  - [x] Link to next tutorial

- [x] Create `docs/tutorials/08-cleanup.md`
  - [x] Why cleanup matters
  - [x] What resources to remove (list with costs)
  - [x] Quick cleanup with script
  - [x] Manual cleanup step-by-step:
    - [x] Delete Cloud Run service
    - [x] Delete Artifact Registry
    - [x] Delete service account (optional)
    - [x] Remove GitHub secrets
    - [x] Clean up local files
  - [x] Verify cleanup
  - [x] What about APIs, logs, repository?
  - [x] Cost verification
  - [x] If you want to redeploy later (options)
  - [x] Common cleanup issues
  - [x] Cleanup checklist
  - [x] Final cost summary
  - [x] What you learned
  - [x] Next steps (keep learning, stay connected)

- [x] Create `docs/tutorials/troubleshooting.md`
  - [x] Table of contents
  - [x] Local development issues (dev container, app won't start, tests failing)
  - [x] Docker issues (build fails, image too large, cannot push)
  - [x] Google Cloud authentication issues
  - [x] Deployment issues (API not enabled, permission denied, timeout, repository not found)
  - [x] Runtime issues (container won't start, crashes, 503, 404, memory limit)
  - [x] GitHub Actions / CI/CD issues (workflow not triggering, auth failed, tests fail in CI, build too long)
  - [x] Performance issues (high latency, high CPU, timeout)
  - [x] Cost issues (unexpected charges, how to reduce costs)
  - [x] Getting more help (check logs, check config, test locally, community resources, file bug report)

### Documentation Updates

- [x] Update `README.md` for gcloud branch
  - [x] Title and badges (Cloud Run, FastAPI, Python)
  - [x] What You'll Build section
  - [x] Complete tutorial series links (01-08)
  - [x] Quick start options (deploy immediately vs learn)
  - [x] Architecture diagram
  - [x] Components list
  - [x] Project structure tree
  - [x] Features section (security, code quality, production ready, developer experience)
  - [x] Cost estimate
  - [x] Development section (local dev, run tests, manual deployment, view logs)
  - [x] CI/CD setup (required secrets, workflow triggers)
  - [x] Monitoring section
  - [x] Cleanup section
  - [x] Other cloud providers links
  - [x] Contributing section
  - [x] Learn more resources
  - [x] License and support

### Update .gitignore

- [x] Add `.gcloud-config` to .gitignore (cloud-specific config file)

### Testing and Verification

- [x] Verify all scripts are executable
- [x] Check all tutorial links work
- [x] Verify README renders correctly
- [x] Test workflow syntax (no errors)

### Commit and Push

- [x] Stage all Phase 2 changes
- [x] Commit with comprehensive message
- [x] Push to gcloud branch
- [x] Merge latest from main if needed

---

## Phase 3: Build GCloud Starter Branch

### Overview
Create a learning-focused branch with TODO markers and guided exercises for students to build the deployment themselves.

### Branch Setup

- [ ] Create `gcloud-starter` branch from `gcloud`
- [ ] Verify it includes all Phase 1 and 2 content

### Add TODO Markers to Scripts

- [ ] Modify `scripts/setup-gcloud.sh`
  - [ ] Comment out functional code
  - [ ] Add TODO markers for each section
  - [ ] Add hints about what needs to be implemented
  - [ ] Keep structure intact with comments
  - [ ] Add reference to tutorial 05 for guidance

- [ ] Modify `scripts/deploy-manual.sh`
  - [ ] Comment out functional code
  - [ ] Add TODO markers for each section
  - [ ] Add hints about Docker commands, gcloud commands
  - [ ] Keep structure with comments
  - [ ] Add reference to tutorial 05

- [ ] Modify `.github/workflows/deploy.yaml`
  - [ ] Keep workflow structure
  - [ ] Add TODO markers for each step
  - [ ] Comment out actual implementation
  - [ ] Add hints about what each step should do
  - [ ] Add reference to tutorial 06

### Create Learning Aids

- [ ] Create `scripts/validate-setup.sh` (executable)
  - [ ] Check if Docker is installed and running
  - [ ] Check if Git is installed
  - [ ] Check if gcloud is available (or note it's in dev container)
  - [ ] Check if VS Code is installed
  - [ ] Display status for each tool
  - [ ] Guide user to next steps

- [ ] Create `scripts/reset.sh` (executable)
  - [ ] Display warning about losing work
  - [ ] Require confirmation
  - [ ] Reset to clean starter state with `git reset --hard origin/gcloud-starter`
  - [ ] Clean untracked files with `git clean -fd`
  - [ ] Display success message

### Create Learning Path Guide

- [ ] Create `docs/tutorials/LEARNING-PATH.md`
  - [ ] Explain starter vs complete branch
  - [ ] Learning journey section:
    - [ ] Phase 1: Setup (30 minutes)
    - [ ] Phase 2: Understand FastAPI (30 minutes)
    - [ ] Phase 3: Manual Deployment (60 minutes)
    - [ ] Phase 4: CI/CD Automation (45 minutes)
    - [ ] Phase 5: Production Skills (30 minutes)
  - [ ] Getting help section
  - [ ] Checkpoints for progress verification
  - [ ] Link to complete branch for reference

### Update README

- [ ] Update `README.md` for gcloud-starter branch
  - [ ] Add banner: "🎓 Learning Branch - Build It Yourself"
  - [ ] Explain this is the starter branch
  - [ ] Link to complete branch for reference
  - [ ] Add "How to Use This Branch" section
  - [ ] Keep all other documentation
  - [ ] Emphasize learning by doing

### Create Exercise Markers in Tutorials

- [ ] Update tutorials to include exercises for starter branch
  - [ ] Mark sections with "✏️ Exercise" headers
  - [ ] Provide hints without giving away answers
  - [ ] Link to complete branch for solutions

### Testing and Verification

- [ ] Verify all TODO markers are clear
- [ ] Test validation script works
- [ ] Test reset script works correctly
- [ ] Ensure nothing is broken (can still run locally)
- [ ] Check tutorials guide students properly

### Commit and Push

- [ ] Commit all Phase 3 changes
- [ ] Push to gcloud-starter branch

---

## Phase 4: Build Azure Complete Branch

### Overview
Create production-ready Azure Container Apps deployment similar to GCloud branch structure.

### Branch Setup

- [ ] Create `azure` branch from main
- [ ] Verify Phase 1 improvements are included

### Development Environment

- [ ] Update `Dockerfile.dev` (azure branch only)
  - [ ] Add Azure CLI installation
  - [ ] Install az cli package
  - [ ] Keep all existing development tools

### Cloud Configuration Files

- [ ] Create `config/` directory

- [ ] Create `config/container-app.yaml`
  - [ ] Azure Container Apps YAML specification
  - [ ] Resource configuration (cpu, memory)
  - [ ] Scaling configuration (minReplicas: 0, maxReplicas: 10)
  - [ ] Ingress configuration
  - [ ] Environment variables
  - [ ] Comments explaining each setting

- [ ] Create `.dockerignore` (or Azure equivalent)
  - [ ] Similar to .gcloudignore
  - [ ] Exclude unnecessary files from deployment

### Helper Scripts

- [ ] Create `scripts/` directory

- [ ] Create `scripts/setup-azure.sh` (executable)
  - [ ] Check if Azure CLI is installed
  - [ ] Login to Azure
  - [ ] Select or create subscription
  - [ ] Create resource group
  - [ ] Create Azure Container Registry
  - [ ] Create Container Apps environment
  - [ ] Configure Docker authentication
  - [ ] Save configuration to .azure-config
  - [ ] Display next steps

- [ ] Create `scripts/deploy-manual.sh` (executable)
  - [ ] Load configuration from .azure-config
  - [ ] Support version tag parameter
  - [ ] Build Docker image
  - [ ] Push to Azure Container Registry
  - [ ] Deploy to Azure Container Apps
  - [ ] Get app URL
  - [ ] Test deployment
  - [ ] Display service endpoints

- [ ] Create `scripts/cleanup.sh` (executable)
  - [ ] Load configuration
  - [ ] Display warning
  - [ ] Delete Container App
  - [ ] Delete Container Registry
  - [ ] Delete Resource Group (optional)
  - [ ] Remove local .azure-config

- [ ] Make all scripts executable

### Production CI/CD Workflow

- [ ] Create `.github/workflows/deploy.yaml`
  - [ ] Name: "Deploy to Azure Container Apps"
  - [ ] Environment variables (SUBSCRIPTION_ID, RESOURCE_GROUP, etc.)
  - [ ] Trigger on push to azure branch
  - [ ] Ignore paths (docs/**, scripts/**, *.md)

- [ ] Test Job
  - [ ] Same as GCloud test job
  - [ ] Run linting, type checking, tests, formatting

- [ ] Deploy Job
  - [ ] Needs: test
  - [ ] Authenticate to Azure (azure/login@v1)
  - [ ] Set up Azure CLI
  - [ ] Build Docker image
  - [ ] Push to Azure Container Registry
  - [ ] Deploy to Azure Container Apps
  - [ ] Get app URL
  - [ ] Verify deployment

### Comprehensive Tutorial Series

- [ ] Create `docs/tutorials/` directory

- [ ] Create tutorials adapted for Azure:
  - [ ] `01-overview.md` - Azure Container Apps focus
  - [ ] `02-prerequisites.md` - Azure CLI, Azure account
  - [ ] `03-local-setup.md` - Same as GCloud
  - [ ] `04-understanding-fastapi.md` - Same as GCloud
  - [ ] `05-manual-deployment.md` - Azure Container Apps deployment
  - [ ] `06-cicd-setup.md` - GitHub Actions for Azure
  - [ ] `07-monitoring.md` - Azure Monitor, Log Analytics
  - [ ] `08-cleanup.md` - Azure resource cleanup
  - [ ] `troubleshooting.md` - Azure-specific issues

### Documentation Updates

- [ ] Update `README.md` for azure branch
  - [ ] Azure-specific badges and links
  - [ ] Azure Container Apps architecture
  - [ ] Azure-specific configuration
  - [ ] Same comprehensive structure as GCloud README

### Update .gitignore

- [ ] Add `.azure-config` to .gitignore

### Testing and Verification

- [ ] Test all scripts work
- [ ] Verify workflow syntax
- [ ] Check tutorial links

### Commit and Push

- [ ] Commit all Phase 4 changes
- [ ] Push to azure branch

---

## Phase 5: Build Azure Starter Branch

### Overview
Create learning branch for Azure similar to gcloud-starter.

### Branch Setup

- [ ] Create `azure-starter` branch from `azure`

### Add TODO Markers

- [ ] Modify `scripts/setup-azure.sh` with TODOs
- [ ] Modify `scripts/deploy-manual.sh` with TODOs
- [ ] Modify `.github/workflows/deploy.yaml` with TODOs

### Create Learning Aids

- [ ] Create `scripts/validate-setup.sh`
  - [ ] Check Docker, Git, VS Code
  - [ ] Check Azure CLI (or note in dev container)
  - [ ] Display status and next steps

- [ ] Create `scripts/reset.sh`
  - [ ] Reset to clean starter state
  - [ ] Confirm before reset

### Create Learning Path Guide

- [ ] Create `docs/tutorials/LEARNING-PATH.md`
  - [ ] Azure-specific learning journey
  - [ ] Checkpoints
  - [ ] Link to complete branch

### Update README

- [ ] Update `README.md` for azure-starter
  - [ ] Learning branch banner
  - [ ] How to use this branch
  - [ ] Link to complete branch

### Testing and Verification

- [ ] Verify TODO markers
- [ ] Test scripts
- [ ] Check tutorials

### Commit and Push

- [ ] Commit all Phase 5 changes
- [ ] Push to azure-starter branch

---

## Final Phase: Main Branch Updates

### Overview
Update main branch README to tie everything together.

### Main Branch README

- [ ] Update `README.md` on main branch
  - [ ] Project overview
  - [ ] Branch structure explanation
  - [ ] Links to all branches:
    - [ ] `main` - Cloud-agnostic base
    - [ ] `gcloud` - Google Cloud (complete)
    - [ ] `gcloud-starter` - Google Cloud (learning)
    - [ ] `azure` - Azure (complete)
    - [ ] `azure-starter` - Azure (learning)
  - [ ] Quick decision tree: "Which branch should I use?"
  - [ ] What's in each branch
  - [ ] Getting started guide
  - [ ] Contributing guidelines
  - [ ] License

### Documentation Index

- [ ] Create `docs/README.md` on main branch
  - [ ] Overview of documentation
  - [ ] Links to tutorials in each branch
  - [ ] Architecture documentation
  - [ ] Contributing guide

### Contributing Guide

- [ ] Create `CONTRIBUTING.md`
  - [ ] How to contribute
  - [ ] Code style guidelines
  - [ ] Testing requirements
  - [ ] Pull request process

### Commit and Push

- [ ] Commit main branch updates
- [ ] Push to main branch

---

## Success Criteria

### Code Quality
- [x] No security issues (conditional debugpy, configurable CORS)
- [x] All tests pass (main branch)
- [ ] All tests pass (gcloud branch)
- [ ] All tests pass (azure branch)
- [x] Linting passes (ruff, black)
- [x] Type checking passes (mypy)
- [x] >80% code coverage

### Documentation
- [x] Complete tutorials that beginners can follow (GCloud)
- [ ] Complete tutorials for Azure
- [x] Concepts explained before implementation (GCloud)
- [x] Architecture diagrams included (GCloud)
- [x] Troubleshooting section comprehensive (GCloud)

### Deployments
- [x] Manual deployment scripts work (GCloud)
- [ ] Manual deployment scripts work (Azure)
- [x] CI/CD workflows deploy successfully (GCloud)
- [ ] CI/CD workflows deploy successfully (Azure)
- [x] Deployed services respond to requests (GCloud)
- [ ] Deployed services respond to requests (Azure)
- [x] Logs and monitoring accessible (GCloud)
- [ ] Logs and monitoring accessible (Azure)

### Learning Experience
- [ ] Starter branches have clear TODOs
- [ ] Students can progress independently
- [ ] Reset script works
- [ ] Validation scripts verify prerequisites

---

## Repository State

### Branches Status

```
✅ main               - Cloud-agnostic base (Phase 1 complete)
✅ gcloud             - Google Cloud complete (Phase 2 complete)
⏳ gcloud-starter     - Google Cloud learning (Phase 3 pending)
⏳ azure              - Azure complete (Phase 4 pending)
⏳ azure-starter      - Azure learning (Phase 5 pending)
```

### Files Created - Phase 1 (Main Branch)

```
✅ src/config.py                      - Environment configuration
✅ src/main.py                         - Updated with security fixes
✅ src/api/__init__.py                 - API module init
✅ src/api/health.py                   - Health check endpoint
✅ src/api/hello.py                    - Hello endpoints (renamed from router)
✅ src/tests/__init__.py               - Tests module init
✅ src/tests/test_api.py               - API endpoint tests
✅ requirements-dev.txt                - Development dependencies
✅ pyproject.toml                      - Tool configurations
✅ .env.example                        - Environment variable template
✅ .gitignore                          - Expanded ignore patterns
✅ .github/workflows/test.yaml         - Test workflow for main
❌ src/smokeTest/                      - DELETED (renamed to api/)
```

### Files Created - Phase 2 (GCloud Branch)

```
✅ Dockerfile.dev                      - Updated with gcloud SDK
✅ config/cloudrun-service.yaml        - Cloud Run configuration
✅ .gcloudignore                       - Deployment exclusions
✅ .gitignore                          - Added .gcloud-config
✅ scripts/setup-gcloud.sh             - GCP setup automation
✅ scripts/deploy-manual.sh            - Manual deployment
✅ scripts/cleanup.sh                  - Resource cleanup
✅ .github/workflows/deploy.yaml       - Production CI/CD
✅ docs/tutorials/01-overview.md       - What you'll build
✅ docs/tutorials/02-prerequisites.md  - Required tools
✅ docs/tutorials/03-local-setup.md    - Dev Container setup
✅ docs/tutorials/04-understanding-fastapi.md - Framework deep-dive
✅ docs/tutorials/05-manual-deployment.md - Cloud Run deployment
✅ docs/tutorials/06-cicd-setup.md     - GitHub Actions setup
✅ docs/tutorials/07-monitoring.md     - Logs and metrics
✅ docs/tutorials/08-cleanup.md        - Resource removal
✅ docs/tutorials/troubleshooting.md   - Common issues
✅ README.md                           - Complete documentation
```

### Commit History

```
✅ bc0fb82 - Remove .vscode directory
✅ 0ebf8a2 - Make main branch cloud-agnostic
✅ 5dbbbee - Phase 1: Fix main branch foundation
✅ b78ba1b - Phase 2: Complete GCloud branch with tutorials and automation
```

---

## Notes and Reminders

### Key Design Decisions

1. **No git history restoration for GCloud**: User chose to start fresh with well-designed files
2. **Starter branches for learning**: Provide TODO-driven learning experience
3. **Conceptual + Practical tutorials**: Explain concepts before implementation
4. **Production-ready CI/CD**: Working workflows, not just examples
5. **Comprehensive documentation**: Detailed but not verbose
6. **Cost transparency**: Clear cost estimates and cleanup instructions

### Important Implementation Details

- Phase 1 security fixes are critical for all branches
- Each cloud branch adds SDK to Dockerfile.dev
- Scripts must be executable (chmod +x)
- Workflows test before deploying
- Tutorials must explain "why" not just "how"
- All secrets use environment variables, never hardcoded
- Cost estimates included in tutorials
- Cleanup scripts prevent runaway costs

### Future Considerations (Deferred)

- AWS branch (App Runner or ECS Fargate)
- DigitalOcean branch (App Platform)
- Linode branch (Kubernetes or similar)
- Multi-cloud comparison documentation
- Cost comparison across clouds
- Performance benchmarking

---

**Last Updated**: Phase 2 completed - GCloud branch with comprehensive tutorials and automation
**Next Step**: Phase 3 - Create gcloud-starter learning branch
**Timeline**: Phases 3-5 pending user request
