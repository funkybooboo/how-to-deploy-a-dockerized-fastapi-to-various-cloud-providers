# Deploy Dockerized FastAPI to Google Cloud Run

A complete tutorial for deploying a containerized FastAPI application to Google Cloud using Cloud Run.

## What You'll Learn

- Set up a local development environment with Dev Containers
- Build a FastAPI application
- Deploy to Google Cloud Run
- Set up CI/CD with GitHub Actions

## Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [VS Code](https://code.visualstudio.com/download)
- A Google Cloud account
- `gcloud` CLI (installed in dev container)

## Tutorial Steps

Follow these guides in order:

1. **[Part 1: Create a Dev Container](./part_1.md)** - Set up local development environment
2. **[Part 2: Build a FastAPI Application](./part_2.md)** - Create FastAPI endpoints
3. **[Part 3: Deploy to Cloud Run](./part_3.md)** - Deploy to Google Cloud Run
4. **[Part 4: Set Up CI/CD](./part_4.md)** - Configure GitHub Actions

## Quick Start

```bash
git clone <repo-url>
cd <repo-name>
git checkout gcloud
code .
# Reopen in Dev Container
```

## Architecture

- **Application:** FastAPI Python web framework
- **Container:** Docker with Python 3.12
- **Registry:** Google Artifact Registry
- **Hosting:** Google Cloud Run (serverless containers)
- **CI/CD:** GitHub Actions

## Other Cloud Providers

See the [main branch README](../../tree/main) for Azure deployment.
