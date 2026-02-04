# Contributing Guide

## Branch Strategy

This repository uses a multi-branch strategy to support multiple cloud providers:

- `main` - Cloud-agnostic application code (base branch)
- `gcloud` - Google Cloud deployment
- `azure` - Microsoft Azure deployment

## Making Changes

### Application Code Changes (affects all clouds)

Changes to the core FastAPI application should be made on `main`:

```bash
git checkout main
git checkout -b feature/my-feature

# Make changes to src/, requirements.txt, Dockerfile.prod, etc.
git commit -m "Add new feature"
git push origin feature/my-feature

# Create PR targeting main
```

After merging to `main`, merge main into all cloud branches:

```bash
for branch in gcloud azure; do
  git checkout $branch
  git merge main
  git push origin $branch
done
```

### Cloud-Specific Changes

Changes specific to one cloud provider should be made on that branch:

```bash
git checkout gcloud
git checkout -b gcloud/fix-deployment

# Make changes to .github/workflows/, cloud configs, etc.
git commit -m "Fix GCloud deployment issue"
git push origin gcloud/fix-deployment

# Create PR targeting gcloud
```

## File Guidelines

### Files on Main (Cloud-Agnostic Only)
- `src/` - Application code
- `requirements.txt` - Python dependencies
- `Dockerfile.prod` - Production container
- `Dockerfile.dev` - Development container (no cloud SDKs)
- `.devcontainer/` - VS Code dev container config
- `.gitignore`, `README.md`, `CONTRIBUTING.md`

### Files on Cloud Branches
- `README.md` - Cloud-specific tutorial
- `part_1.md - part_4.md` - Tutorial steps
- `.github/workflows/` - Cloud-specific CI/CD
- Cloud provider configs (e.g., `cloudbuild.yaml` for GCloud, `azure-container-app.yaml` for Azure)
- Cloud-specific scripts and setup files

### Dockerfile.dev Customization
Cloud branches MAY customize `Dockerfile.dev` to include cloud-specific SDKs (gcloud CLI, Azure CLI, etc.) for local development convenience.
