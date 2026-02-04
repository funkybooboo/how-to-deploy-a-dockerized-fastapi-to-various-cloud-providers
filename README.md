# How to Deploy a Dockerized FastAPI to Cloud Providers

This repository contains tutorials for deploying a containerized FastAPI application to multiple cloud providers.

## Supported Cloud Providers

Choose your cloud provider to get started:

- **[Google Cloud (GCloud)](../../tree/gcloud)** - Deploy to Cloud Run
- **[Microsoft Azure](../../tree/azure)** - Deploy to Container Apps

## What's Included

This `main` branch contains the shared, cloud-agnostic components:

- FastAPI application (`src/`)
- Production Dockerfile (`Dockerfile.prod`)
- Development Dockerfile (`Dockerfile.dev`)
- Dev Container configuration (`.devcontainer/`)
- Python dependencies (`requirements.txt`)

## Getting Started

1. **Choose your cloud provider** from the list above
2. **Switch to that branch** (e.g., `git checkout gcloud`)
3. **Follow the tutorial** in that branch's README

## Repository Structure

- `main` - Shared application code (this branch)
- `gcloud` - Google Cloud deployment
- `azure` - Microsoft Azure deployment

Each cloud branch builds on top of `main` and adds cloud-specific configuration and documentation.

## Local Development

The application can be run locally using Docker or the VS Code Dev Container:

```bash
# Using Docker
docker build -f Dockerfile.dev -t fastapi-dev .
docker run -p 8080:8080 fastapi-dev

# Or open in VS Code and use "Reopen in Container"
```
