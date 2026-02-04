# Overview: Deploying FastAPI to Google Cloud Run

## What You'll Build

In this tutorial series, you'll deploy a production-ready FastAPI application to Google Cloud Run with automated CI/CD. Here's what you'll create:

- **FastAPI REST API** - Modern Python web framework with automatic API documentation
- **Docker Container** - Portable, isolated deployment package
- **Cloud Run Service** - Serverless auto-scaling hosting on Google Cloud
- **GitHub Actions CI/CD** - Automated build, test, and deployment pipeline

## Architecture

```
┌─────────────┐      ┌──────────────┐      ┌─────────────┐
│   GitHub    │─────▶│GitHub Actions│─────▶│  Artifact   │
│ Repository  │      │   (CI/CD)    │      │  Registry   │
└─────────────┘      └──────────────┘      └─────────────┘
                                                   │
                                                   ▼
┌─────────────┐                           ┌─────────────┐
│   Users     │◀──────────────────────────│  Cloud Run  │
│             │    HTTPS (auto-cert)      │  (Service)  │
└─────────────┘                           └─────────────┘
```

## What is Cloud Run?

**Cloud Run** is Google's serverless container platform. Key features:

- **Auto-scaling**: Automatically scales from 0 to 1000+ instances based on traffic
- **Pay-per-use**: Only charged when requests are being processed (no idle costs)
- **Fully managed**: No server maintenance, patching, or infrastructure management required
- **HTTPS included**: Automatic SSL certificates and custom domain support
- **Container-based**: Run any language, library, or binary packaged in a container

### Why Cloud Run?

Traditional hosting requires you to:
- Provision servers
- Configure auto-scaling
- Manage SSL certificates
- Handle load balancing
- Patch and maintain infrastructure

Cloud Run handles all of this automatically. You just provide a container, and Google manages everything else.

## Learning Outcomes

By completing this tutorial series, you will understand:

1. **Containerization** - Package applications with Docker for consistent deployments
2. **Serverless Deployment** - Deploy without managing servers or infrastructure
3. **CI/CD Automation** - Automate build, test, and deploy cycles with GitHub Actions
4. **Cloud Services** - Work with Google Cloud Artifact Registry and Cloud Run
5. **Production Practices** - Environment variables, logging, monitoring, and security

## Prerequisites

Before starting, you need:

- **Basic Python knowledge** - Understanding of functions, classes, and modules
- **Basic command-line skills** - Comfortable with terminal/command prompt
- **A Google Cloud account** - Free tier available with $300 credit for new users
- **A GitHub account** - For storing code and running CI/CD

No prior Docker or cloud experience required - we'll explain everything as we go.

## Time Estimate

- **Local Development Setup**: 20-30 minutes
- **Understanding FastAPI**: 30 minutes
- **Manual Deployment**: 45-60 minutes
- **CI/CD Setup**: 30-45 minutes
- **Monitoring & Cleanup**: 15 minutes
- **Total**: ~3 hours (can be split across multiple sessions)

## Cost Estimate

Google Cloud offers a generous free tier:

**Free Tier (Always Free):**
- 2 million requests per month
- 360,000 GB-seconds of memory per month
- 180,000 vCPU-seconds per month

**Beyond Free Tier:**
- ~$0.024 per additional 1M requests
- ~$0.00001800 per GB-second of memory
- ~$0.00002400 per vCPU-second

**Example Cost:**
- Small API with 10M requests/month: ~$15-20/month
- Medium API with 50M requests/month: ~$75-100/month

**Tips to Stay in Free Tier:**
- Scale to zero when idle (default configuration)
- Use appropriate memory/CPU limits (512MB/1 vCPU is plenty for most apps)
- Monitor usage in Cloud Console

## Tutorial Structure

### Part 1: Local Development (Tutorials 2-4)
1. **Prerequisites** - Install required tools
2. **Local Setup** - Set up development environment with VS Code Dev Container
3. **Understanding FastAPI** - Learn the framework and explore the codebase

### Part 2: Cloud Deployment (Tutorials 5-6)
4. **Manual Deployment** - Deploy step-by-step to understand each component
5. **CI/CD Setup** - Automate deployments with GitHub Actions

### Part 3: Production Skills (Tutorials 7-8)
6. **Monitoring & Debugging** - View logs, metrics, and troubleshoot issues
7. **Cleanup** - Remove resources to avoid ongoing charges

## What's Different About This Tutorial?

This tutorial focuses on **understanding**, not just following commands:

- **Concepts First**: We explain *why* before showing *how*
- **Production-Ready**: Real-world configuration, not toy examples
- **Complete Automation**: From code commit to live deployment
- **Straightforward**: Clear explanations without unnecessary complexity

## Ready to Start?

Continue to [02-prerequisites.md](./02-prerequisites.md) to install the required tools and verify your setup.

---

**Need Help?**
- Check [troubleshooting.md](./troubleshooting.md) for common issues
- Review [README.md](../../README.md) for quick reference
