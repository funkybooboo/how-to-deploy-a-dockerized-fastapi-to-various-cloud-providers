# Troubleshooting Guide

This guide covers common issues you might encounter while deploying FastAPI to Google Cloud Run, with solutions.

## Table of Contents

- [Local Development Issues](#local-development-issues)
- [Docker Issues](#docker-issues)
- [Google Cloud Authentication](#google-cloud-authentication)
- [Deployment Issues](#deployment-issues)
- [Runtime Issues](#runtime-issues)
- [GitHub Actions / CI/CD Issues](#github-actions--cicd-issues)
- [Performance Issues](#performance-issues)
- [Cost Issues](#cost-issues)

---

## Local Development Issues

### Dev Container Won't Start

**Error:** "Failed to start dev container"

**Causes & Solutions:**

1. **Docker not running**
   ```bash
   # Check if Docker is running
   docker info

   # If error, start Docker Desktop
   ```

2. **Insufficient resources**
   - Docker Desktop → Settings → Resources
   - Increase Memory to at least 4GB
   - Increase Disk space to at least 10GB

3. **Port already in use**
   ```bash
   # Find process using port 8080
   lsof -i :8080  # macOS/Linux
   netstat -ano | findstr :8080  # Windows

   # Kill the process or use different port in devcontainer.json
   ```

4. **Corrupted cache**
   ```bash
   # Rebuild container from scratch
   # F1 → "Dev Containers: Rebuild Container Without Cache"
   ```

### Application Won't Start

**Error:** `ModuleNotFoundError: No module named 'fastapi'`

**Solution:**
```bash
# Inside dev container
pip install -r requirements.txt
pip install -r requirements-dev.txt
```

**Error:** `ImportError: cannot import name 'app' from 'src.main'`

**Solution:**
```bash
# Check PYTHONPATH is set
echo $PYTHONPATH
# Should include /code or /workspaces/...

# If not, set it
export PYTHONPATH=/code
```

### Tests Failing Locally

**Error:** Tests pass sometimes, fail other times

**Cause:** Test order dependency or async issues

**Solution:**
```bash
# Run tests in random order
pytest src/tests/ --random-order

# Run tests with verbose output
pytest src/tests/ -vv

# Run specific test
pytest src/tests/test_api.py::test_hello_endpoint -v
```

---

## Docker Issues

### Docker Build Fails

**Error:** `ERROR [internal] load metadata for docker.io/library/python:3.12-slim`

**Cause:** Cannot reach Docker Hub

**Solution:**
```bash
# Check internet connection
ping docker.io

# Try with different base image
# Edit Dockerfile.prod:
FROM python:3.12-slim-bookworm
```

**Error:** `failed to solve with frontend dockerfile.v0`

**Cause:** Syntax error in Dockerfile

**Solution:**
- Check Dockerfile for typos
- Ensure all COPY paths exist
- Verify requirements.txt exists

### Docker Image Too Large

**Problem:** Image is > 1GB

**Solution:**
```dockerfile
# Use slim base image (not full)
FROM python:3.12-slim

# Multi-stage build
FROM python:3.12 as builder
WORKDIR /install
COPY requirements.txt .
RUN pip install --prefix=/install -r requirements.txt

FROM python:3.12-slim
COPY --from=builder /install /usr/local
COPY ./src ./src
```

### Cannot Push to Artifact Registry

**Error:** `denied: Permission denied for "push" operation`

**Solution:**
```bash
# Re-configure Docker authentication
gcloud auth configure-docker us-central1-docker.pkg.dev

# Verify authentication
gcloud auth list
# Should show ACTIVE account

# Check Artifact Registry repository exists
gcloud artifacts repositories describe fastapi-repo \
    --location us-central1
```

---

## Google Cloud Authentication

### `gcloud: command not found`

**Solution:**

**If using Dev Container:**
- gcloud should be pre-installed
- Restart VS Code
- Rebuild container

**If not using Dev Container:**
```bash
# Install gcloud
# macOS
brew install google-cloud-sdk

# Linux
curl https://sdk.cloud.google.com | bash

# Windows
# Download from: https://cloud.google.com/sdk/docs/install
```

### Authentication Fails

**Error:** `ERROR: (gcloud.auth.login) Could not reach authentication endpoint`

**Solution:**
```bash
# Check internet connection
ping google.com

# Try alternative auth method
gcloud auth login --no-launch-browser
# Follow the provided URL and paste the code
```

### Wrong Project Selected

**Error:** `Project [wrong-project] not found`

**Solution:**
```bash
# List available projects
gcloud projects list

# Set correct project
gcloud config set project YOUR_CORRECT_PROJECT_ID

# Verify
gcloud config get-value project
```

---

## Deployment Issues

### API Not Enabled

**Error:** `API [run.googleapis.com] not enabled on project`

**Solution:**
```bash
# Enable required APIs
gcloud services enable run.googleapis.com
gcloud services enable artifactregistry.googleapis.com
gcloud services enable cloudbuild.googleapis.com

# Verify
gcloud services list --enabled | grep -E 'run|artifact'
```

### Permission Denied

**Error:** `Permission denied on resource project [project-id]`

**Solution:**
```bash
# Check your permissions
gcloud projects get-iam-policy $(gcloud config get-value project) \
    --flatten="bindings[].members" \
    --filter="bindings.members:user:$(gcloud config get-value account)"

# You need one of:
# - roles/owner
# - roles/editor
# - roles/run.admin + roles/artifactregistry.admin

# Contact project owner to grant permissions
```

### Deployment Timeout

**Error:** `Deployment timed out`

**Cause:** Large image or slow pull

**Solution:**
```bash
# Deploy with longer timeout
gcloud run deploy fastapi-service \
    --image IMAGE \
    --region us-central1 \
    --timeout 900  # 15 minutes max
```

### Repository Not Found

**Error:** `repository "fastapi-repo" not found`

**Solution:**
```bash
# Create repository
gcloud artifacts repositories create fastapi-repo \
    --repository-format=docker \
    --location=us-central1

# Verify
gcloud artifacts repositories list --location us-central1
```

---

## Runtime Issues

### Container Won't Start

**Error:** `Cloud Run error: Container failed to start`

**Causes & Solutions:**

1. **Port mismatch**
   ```python
   # Dockerfile.prod must listen on port 8080
   CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8080"]
   ```

2. **Missing dependencies**
   ```bash
   # Check logs
   gcloud run services logs tail fastapi-service --region us-central1

   # Look for ModuleNotFoundError
   # Add missing packages to requirements.txt
   ```

3. **Syntax errors**
   ```bash
   # Test image locally first
   docker run -p 8080:8080 YOUR_IMAGE
   # Check for Python syntax errors in logs
   ```

### Application Crashes After Start

**Symptom:** Container starts but immediately exits

**Debug:**
```bash
# View logs
gcloud run services logs read fastapi-service \
    --region us-central1 \
    --limit 100

# Look for:
# - Python exceptions
# - Import errors
# - Configuration errors
```

### 503 Service Unavailable

**Causes:**

1. **Container not healthy**
   - Check logs for startup errors
   - Verify container runs locally

2. **Too many requests**
   - Container hitting max-instances limit
   - Increase max-instances

3. **Cold start timeout**
   - Container takes too long to start
   - Optimize startup time
   - Use min-instances > 0

**Debug:**
```bash
# Check current configuration
gcloud run services describe fastapi-service \
    --region us-central1 \
    --format=yaml
```

### 404 Not Found

**Causes:**

1. **Wrong path**
   ```bash
   # Correct: /api/hello
   # Wrong: /hello

   # Check API_PREFIX in config
   ```

2. **Route not defined**
   ```python
   # Verify router is included in main.py
   app.include_router(hello.router, prefix=settings.API_PREFIX)
   ```

### Memory Limit Exceeded

**Error:** `Container exceeded memory limit`

**Solution:**
```bash
# Check memory usage in metrics
# Increase memory limit
gcloud run services update fastapi-service \
    --region us-central1 \
    --memory 1Gi  # or 2Gi, 4Gi

# Optimize application memory usage
# - Use connection pooling
# - Limit concurrent requests
# - Fix memory leaks
```

---

## GitHub Actions / CI/CD Issues

### Workflow Not Triggering

**Causes:**

1. **Wrong branch**
   ```bash
   # Check current branch
   git branch

   # Should be 'gcloud' for deployment workflow
   git checkout gcloud
   ```

2. **Only docs changed**
   ```yaml
   # Workflow ignores docs changes
   paths-ignore:
     - 'docs/**'

   # Make a code change to trigger
   ```

3. **Workflow disabled**
   - Check GitHub → Actions → workflow status

### Authentication Failed

**Error:** `Failed to authenticate to Google Cloud`

**Causes & Solutions:**

1. **Missing secrets**
   - Go to GitHub → Settings → Secrets → Actions
   - Verify `GCP_PROJECT_ID` and `GCP_SA_KEY` exist

2. **Invalid service account key**
   ```bash
   # Generate new key
   gcloud iam service-accounts keys create new-key.json \
       --iam-account=github-actions@PROJECT_ID.iam.gserviceaccount.com

   # Update GitHub secret with new key
   cat new-key.json
   ```

3. **Service account deleted**
   ```bash
   # Check if service account exists
   gcloud iam service-accounts list | grep github-actions

   # Recreate if needed (see tutorial 06)
   ```

### Tests Fail in CI But Pass Locally

**Causes:**

1. **Environment differences**
   ```yaml
   # Add to workflow
   env:
     ENVIRONMENT: testing
     DEBUG: false
   ```

2. **Missing dependencies**
   ```bash
   # Check requirements-dev.txt is installed
   pip install -r requirements-dev.txt
   ```

3. **Python version mismatch**
   ```yaml
   # Workflow should use same version as local
   - uses: actions/setup-python@v5
     with:
       python-version: '3.12'  # Match your local version
   ```

### Build Takes Too Long

**Problem:** Workflow takes > 10 minutes

**Solutions:**

1. **Enable caching**
   ```yaml
   - uses: actions/setup-python@v5
     with:
       python-version: '3.12'
       cache: 'pip'  # Caches pip packages
   ```

2. **Use smaller image**
   ```dockerfile
   FROM python:3.12-slim  # Not python:3.12
   ```

3. **Reduce dependencies**
   - Remove unused packages from requirements.txt

---

## Performance Issues

### High Latency

**Problem:** Requests take > 1 second

**Causes & Solutions:**

1. **Cold starts**
   ```bash
   # Use min-instances to keep warm
   gcloud run services update fastapi-service \
       --region us-central1 \
       --min-instances 1  # Costs more but faster
   ```

2. **External API calls**
   ```python
   # Add caching
   from functools import lru_cache

   @lru_cache(maxsize=100)
   def expensive_operation():
       # ...
   ```

3. **Database queries**
   - Add indexes
   - Use connection pooling
   - Cache frequently accessed data

4. **Insufficient resources**
   ```bash
   # Increase CPU
   gcloud run services update fastapi-service \
       --region us-central1 \
       --cpu 2
   ```

### High CPU Usage

**Debug:**
```bash
# Check metrics
# Cloud Console → Cloud Run → fastapi-service → Metrics

# Profile application
python -m cProfile -o profile.stats src/main.py
```

**Solutions:**
- Optimize algorithms
- Use caching
- Increase CPU allocation

### Request Timeout

**Error:** `Deadline exceeded`

**Solution:**
```bash
# Increase timeout (max 60 minutes)
gcloud run services update fastapi-service \
    --region us-central1 \
    --timeout 600  # 10 minutes
```

---

## Cost Issues

### Unexpected Charges

**Debug:**
```bash
# Check current costs
# Cloud Console → Billing → Reports
# Filter by Cloud Run and Artifact Registry

# Check current month's usage
gcloud run services describe fastapi-service \
    --region us-central1 \
    --format='value(status.traffic[0].revisionName)'
```

**Common causes:**

1. **Not scaling to zero**
   ```bash
   # Verify min-instances is 0
   gcloud run services describe fastapi-service \
       --region us-central1 \
       --format='value(spec.template.metadata.annotations.autoscaling.knative.dev/minScale)'

   # Should output: 0
   ```

2. **Large container images**
   - Artifact Registry charges for storage
   - Delete old images:
   ```bash
   # List images
   gcloud artifacts docker images list \
       us-central1-docker.pkg.dev/PROJECT_ID/fastapi-repo

   # Delete old images
   gcloud artifacts docker images delete IMAGE_PATH --quiet
   ```

3. **Health check traffic**
   - Uptime checks generate requests (minimal cost)

### How to Reduce Costs

```bash
# 1. Scale to zero when idle
gcloud run services update fastapi-service \
    --region us-central1 \
    --min-instances 0

# 2. Use appropriate memory
gcloud run services update fastapi-service \
    --region us-central1 \
    --memory 512Mi  # Not 2Gi if you don't need it

# 3. Delete unused images
./scripts/cleanup.sh

# 4. Set up budget alerts
# Cloud Console → Billing → Budgets & alerts
```

---

## Getting More Help

### Check Logs

Always start with logs:
```bash
# Recent errors
gcloud run services logs read fastapi-service \
    --region us-central1 \
    --filter='severity>=ERROR' \
    --limit 50

# Specific time
gcloud run services logs read fastapi-service \
    --region us-central1 \
    --filter='timestamp>="2024-01-15T10:00:00Z"'
```

### Check Service Configuration

```bash
# View full configuration
gcloud run services describe fastapi-service \
    --region us-central1 \
    --format=yaml > service-config.yaml

# Review for issues
cat service-config.yaml
```

### Test Locally First

Before deploying, always test locally:
```bash
# Build production image
docker build -f Dockerfile.prod -t test-image .

# Run locally
docker run -p 8080:8080 \
    -e ENVIRONMENT=production \
    -e DEBUG=false \
    test-image

# Test endpoints
curl http://localhost:8080/api/health
```

### Community Resources

- **GitHub Issues**: [Repository Issues](../../issues)
- **GitHub Discussions**: [Repository Discussions](../../discussions)
- **Stack Overflow**: Tag `google-cloud-run` + `fastapi`
- **Google Cloud Support**: [cloud.google.com/support](https://cloud.google.com/support)
- **FastAPI Discord**: [discord.gg/fastapi](https://discord.gg/fastapi)

### File a Bug Report

If you find an issue with this tutorial:

1. Check if it's already reported in [Issues](../../issues)
2. Create new issue with:
   - Clear description
   - Steps to reproduce
   - Expected vs actual behavior
   - Error messages and logs
   - Your environment (OS, Python version, etc.)

---

**Still stuck?** Double-check:
- [ ] Followed prerequisites in [02-prerequisites.md](./02-prerequisites.md)
- [ ] Using correct branch (`git branch`)
- [ ] Authenticated to Google Cloud (`gcloud auth list`)
- [ ] Correct project selected (`gcloud config get-value project`)
- [ ] APIs enabled (`gcloud services list --enabled`)
- [ ] Checked logs for errors
- [ ] Tested locally first
