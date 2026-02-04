# Prerequisites: Required Tools and Accounts

This tutorial covers the tools and accounts you'll need to complete the deployment tutorials.

## Required Tools

### 1. Git

**What it is:** Version control system for tracking code changes.

**Why you need it:** Clone this repository and manage code changes.

**Install:**
- **macOS**: `brew install git` or download from [git-scm.com](https://git-scm.com/)
- **Windows**: Download from [git-scm.com](https://git-scm.com/)
- **Linux**: `sudo apt-get install git` (Ubuntu/Debian) or `sudo yum install git` (RedHat/CentOS)

**Verify:**
```bash
git --version
# Should output: git version 2.x.x
```

### 2. Docker Desktop

**What it is:** Platform for building and running containers.

**Why you need it:** Build Docker images and run the development environment.

**Install:**
- **macOS**: Download from [docker.com/products/docker-desktop](https://www.docker.com/products/docker-desktop)
- **Windows**: Download from [docker.com/products/docker-desktop](https://www.docker.com/products/docker-desktop)
- **Linux**: Follow instructions at [docs.docker.com/engine/install](https://docs.docker.com/engine/install/)

**Verify:**
```bash
docker --version
# Should output: Docker version 24.x.x or later

docker info
# Should show Docker is running
```

**Note:** Docker Desktop must be running before you can build or run containers.

### 3. Visual Studio Code (VS Code)

**What it is:** Code editor with excellent Docker and remote development support.

**Why you need it:** Provides Dev Container support for consistent development environment.

**Install:**
- Download from [code.visualstudio.com](https://code.visualstudio.com/)

**Required Extensions:**
After installing VS Code, install these extensions:

1. **Dev Containers** (`ms-vscode-remote.remote-containers`)
   - Allows opening the project in a containerized environment
   - Install from VS Code Extensions marketplace

**Verify:**
```bash
code --version
# Should output VS Code version
```

### 4. Google Cloud CLI (gcloud)

**What it is:** Command-line tool for interacting with Google Cloud services.

**Why you need it:** Deploy and manage Cloud Run services.

**Options:**

**Option A: Install on your local machine**
- **macOS**: `brew install google-cloud-sdk`
- **Windows**: Download installer from [cloud.google.com/sdk/docs/install](https://cloud.google.com/sdk/docs/install)
- **Linux**: Follow instructions at [cloud.google.com/sdk/docs/install](https://cloud.google.com/sdk/docs/install)

**Option B: Use Dev Container (Recommended)**
- The gcloud CLI is pre-installed in the Dev Container
- No local installation needed if you use VS Code Dev Containers

**Verify:**
```bash
gcloud --version
# Should output: Google Cloud SDK version
```

## Required Accounts

### 1. Google Cloud Account

**What it is:** Account for accessing Google Cloud Platform services.

**Why you need it:** Deploy your application to Cloud Run.

**Setup:**
1. Go to [cloud.google.com](https://cloud.google.com/)
2. Click "Get started for free"
3. Sign in with your Google account
4. Complete billing setup (required even for free tier)
   - New users get $300 credit for 90 days
   - Free tier continues after credits expire
   - No charges without explicit upgrade

**Create a Project:**
1. Go to [console.cloud.google.com](https://console.cloud.google.com/)
2. Click project dropdown at top
3. Click "New Project"
4. Enter project name (e.g., "fastapi-deployment")
5. Note your **Project ID** - you'll need this later

### 2. GitHub Account

**What it is:** Platform for hosting Git repositories and running CI/CD workflows.

**Why you need it:** Store code and automate deployments with GitHub Actions.

**Setup:**
1. Go to [github.com](https://github.com/)
2. Click "Sign up"
3. Create your account

**Fork or Clone This Repository:**
```bash
# Option A: Clone directly (if you have write access)
git clone <repository-url>
cd how-to-deploy-a-dockerized-fastapi-to-various-cloud-providers
git checkout gcloud

# Option B: Fork first (recommended)
# 1. Click "Fork" button on GitHub
# 2. Clone your fork:
git clone https://github.com/YOUR-USERNAME/how-to-deploy-a-dockerized-fastapi-to-various-cloud-providers.git
cd how-to-deploy-a-dockerized-fastapi-to-various-cloud-providers
git checkout gcloud
```

## Verification Checklist

Run these commands to verify everything is installed:

```bash
# Check Git
git --version

# Check Docker
docker --version
docker info

# Check VS Code
code --version

# Check gcloud (if installed locally)
gcloud --version
```

**Expected Results:**
- All commands should run without errors
- Docker info should show "Server running"
- VS Code should open when running `code .`

## Common Issues

### Docker Desktop Not Running

**Problem:** `docker info` shows error: "Cannot connect to Docker daemon"

**Solution:**
- Open Docker Desktop application
- Wait for Docker to start (icon in system tray should be steady, not animated)
- Try `docker info` again

### gcloud Not Found

**Problem:** `gcloud: command not found`

**Solutions:**
1. If using Dev Container: This is fine - gcloud will be available inside the container
2. If not using Dev Container: Install gcloud from [cloud.google.com/sdk/docs/install](https://cloud.google.com/sdk/docs/install)
3. Check if gcloud is in your PATH: `echo $PATH | grep google-cloud-sdk`

### VS Code Dev Containers Extension Not Working

**Problem:** "Reopen in Container" option not available

**Solution:**
1. Ensure Docker Desktop is running
2. Install the "Dev Containers" extension: `ms-vscode-remote.remote-containers`
3. Restart VS Code
4. Check that `.devcontainer/devcontainer.json` exists in the project

## Next Steps

Once all prerequisites are installed and verified, continue to [03-local-setup.md](./03-local-setup.md) to set up your development environment.

---

**Need Help?**
- Google Cloud documentation: [cloud.google.com/docs](https://cloud.google.com/docs)
- Docker documentation: [docs.docker.com](https://docs.docker.com/)
- VS Code Dev Containers: [code.visualstudio.com/docs/devcontainers/containers](https://code.visualstudio.com/docs/devcontainers/containers)
