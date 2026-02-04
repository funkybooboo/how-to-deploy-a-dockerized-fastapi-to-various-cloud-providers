# Manual Deployment to Google Cloud Run

This tutorial walks you through manually deploying your FastAPI application to Google Cloud Run, explaining each step and concept.

## Understanding Cloud Run

### What is Cloud Run?

Cloud Run is a **serverless container platform** that runs your Docker containers without managing servers.

**Key Concepts:**

1. **Serverless** - No servers to provision, patch, or manage
2. **Container-based** - Runs any containerized application
3. **Auto-scaling** - Scales from 0 to 1000+ instances based on traffic
4. **Pay-per-use** - Only charged when processing requests

### How Cloud Run Works

```
1. You provide: Docker container image
                ↓
2. Cloud Run:   Deploys to managed infrastructure
                ↓
3. User request arrives
                ↓
4. Cloud Run:   Spins up container instance (if needed)
                ↓
5. Container:   Processes request, returns response
                ↓
6. Cloud Run:   Scales down to zero if no traffic
```

### Cloud Run vs Traditional Hosting

| Feature | Cloud Run | Traditional Server |
|---------|-----------|-------------------|
| Server Management | None | Full responsibility |
| Scaling | Automatic | Manual configuration |
| Cost When Idle | $0 | Full server cost |
| SSL Certificate | Included | Manual setup |
| Cold Start | ~1-2 seconds | N/A |
| Max Request Time | 60 minutes | Unlimited |

### Cold Starts

**What is a cold start?**
When scaled to zero, the first request takes longer because Cloud Run must:
1. Pull container image
2. Start container
3. Initialize your application
4. Process the request

**Typical cold start times:**
- Simple FastAPI app: 1-2 seconds
- Heavy dependencies: 3-5 seconds

**How to minimize:**
- Keep container image small
- Use `--min-instances 1` (costs more but eliminates cold starts)
- Optimize application startup time

## Understanding the Components

### 1. Artifact Registry

**What is it?** A private Docker registry for storing container images.

**Why use it?** Cloud Run needs to pull your Docker image from somewhere secure.

**Alternatives:**
- Docker Hub (public images only, less secure)
- Container Registry (older Google service, Artifact Registry is newer)

**Structure:**
```
LOCATION-docker.pkg.dev/PROJECT-ID/REPOSITORY/IMAGE:TAG
```

Example:
```
us-central1-docker.pkg.dev/my-project/fastapi-repo/fastapi:v1
```

### 2. Service Account

**What is it?** An identity for applications (not humans) with specific permissions.

**Why use it?** GitHub Actions needs permission to deploy without using your personal credentials.

**Required permissions for CI/CD:**
- `Cloud Run Admin` - Deploy and manage services
- `Artifact Registry Writer` - Push container images
- `Service Account User` - Act as service account

### 3. Container Image

**What is it?** Your application packaged with all dependencies.

**Why use it?** Ensures identical environment in development and production.

**Our Dockerfile.prod:**
- Base: Python 3.12 slim
- Dependencies: From requirements.txt
- Code: Copied from src/
- Entry point: Uvicorn server

## Prerequisites Check

Before deploying, verify:

```bash
# Authenticated with Google Cloud
gcloud auth list
# Should show your account as active

# Correct project selected
gcloud config get-value project
# Should show your project ID

# Docker is running
docker info
# Should show server information
```

If any fail, review [02-prerequisites.md](./02-prerequisites.md).

## Step-by-Step Deployment

### Step 1: Authenticate with Google Cloud

If not already authenticated:

```bash
gcloud auth login
```

This opens a browser window to sign in with your Google account.

**Verify authentication:**
```bash
gcloud auth list
# Look for ACTIVE next to your account
```

### Step 2: Set Your Project

```bash
# List available projects
gcloud projects list

# Set your active project
gcloud config set project YOUR_PROJECT_ID

# Verify
gcloud config get-value project
```

**Important:** Replace `YOUR_PROJECT_ID` with your actual project ID from the Cloud Console.

### Step 3: Run Setup Script

We've provided a script that automates the setup:

```bash
chmod +x scripts/setup-gcloud.sh
./scripts/setup-gcloud.sh
```

**This script:**
1. Verifies gcloud CLI is installed
2. Prompts for project ID (or uses current project)
3. Enables required APIs:
   - `run.googleapis.com` - Cloud Run
   - `artifactregistry.googleapis.com` - Artifact Registry
   - `cloudbuild.googleapis.com` - Cloud Build (optional)
4. Creates Artifact Registry repository
5. Configures Docker authentication
6. Saves configuration to `.gcloud-config`

**Expected output:**
```
🚀 Setting up Google Cloud environment for FastAPI deployment
✅ gcloud CLI found
Current project: my-project-123
Use this project? (y/n): y
📦 Enabling required Google Cloud APIs...
...
✅ Setup complete!
```

**What happens behind the scenes:**

#### Enable APIs:
```bash
gcloud services enable run.googleapis.com \
                      artifactregistry.googleapis.com \
                      cloudbuild.googleapis.com
```

APIs are disabled by default to save costs. These commands enable the services we need.

#### Create Artifact Registry:
```bash
gcloud artifacts repositories create fastapi-repo \
    --repository-format=docker \
    --location=us-central1 \
    --description="FastAPI Docker repository"
```

- `fastapi-repo`: Name of the registry
- `--repository-format=docker`: Store Docker images
- `--location=us-central1`: Physical region (choose nearest)

#### Configure Docker:
```bash
gcloud auth configure-docker us-central1-docker.pkg.dev
```

Adds credentials to `~/.docker/config.json` so Docker can push to Artifact Registry.

### Step 4: Build Docker Image

Build the production container image:

```bash
# Get your project ID
PROJECT_ID=$(gcloud config get-value project)

# Build image
docker build -f Dockerfile.prod \
    -t us-central1-docker.pkg.dev/${PROJECT_ID}/fastapi-repo/fastapi:v1 \
    .
```

**Understanding the command:**
- `-f Dockerfile.prod`: Use production Dockerfile (not dev)
- `-t`: Tag the image with a name
- `us-central1-docker.pkg.dev`: Artifact Registry host
- `${PROJECT_ID}`: Your GCP project
- `/fastapi-repo`: Repository we created
- `/fastapi:v1`: Image name and version tag
- `.`: Build context (current directory)

**What happens during build:**
```
Step 1: FROM python:3.12-slim
  ↓ Downloads Python 3.12 base image

Step 2: COPY requirements.txt
  ↓ Copies dependency file

Step 3: RUN pip install
  ↓ Installs FastAPI, Uvicorn, etc.

Step 4: COPY ./src ./src
  ↓ Copies application code

Step 5: CMD uvicorn...
  ↓ Sets container entry point
```

**Verify build:**
```bash
docker images | grep fastapi
# Should show your newly built image
```

### Step 5: Test Image Locally

Before pushing to the cloud, test locally:

```bash
docker run -p 8080:8080 \
    -e ENVIRONMENT=production \
    -e DEBUG=false \
    us-central1-docker.pkg.dev/${PROJECT_ID}/fastapi-repo/fastapi:v1
```

**Visit:** `http://localhost:8080/`

Should show: `{"message": "OK 🚀", "environment": "production"}`

Press `Ctrl+C` to stop.

### Step 6: Push Image to Artifact Registry

Upload your image to Google Cloud:

```bash
docker push us-central1-docker.pkg.dev/${PROJECT_ID}/fastapi-repo/fastapi:v1
```

**This takes 2-5 minutes** depending on your internet speed.

**Progress output:**
```
The push refers to repository [us-central1-docker.pkg.dev/...]
a1b2c3d4e5f6: Pushed
...
v1: digest: sha256:abc123... size: 2841
```

**Verify in Cloud Console:**
1. Visit: https://console.cloud.google.com/artifacts
2. Click on `fastapi-repo`
3. You should see your image listed

### Step 7: Deploy to Cloud Run

Now deploy the image to Cloud Run:

```bash
gcloud run deploy fastapi-service \
    --image us-central1-docker.pkg.dev/${PROJECT_ID}/fastapi-repo/fastapi:v1 \
    --region us-central1 \
    --platform managed \
    --allow-unauthenticated \
    --port 8080 \
    --cpu 1 \
    --memory 512Mi \
    --min-instances 0 \
    --max-instances 10 \
    --concurrency 80 \
    --timeout 300 \
    --set-env-vars "ENVIRONMENT=production,DEBUG=false,LOG_LEVEL=INFO"
```

**Let's break down each parameter:**

**Basic Configuration:**
- `fastapi-service`: Name of your Cloud Run service
- `--image`: Container image to deploy
- `--region us-central1`: Where to deploy (choose nearest)
- `--platform managed`: Use fully managed Cloud Run (not Anthos)

**Access Control:**
- `--allow-unauthenticated`: Make API publicly accessible
  - Remove this flag for private APIs that require authentication

**Container Configuration:**
- `--port 8080`: Port your container listens on
  - Must match the port in your Dockerfile

**Resources:**
- `--cpu 1`: 1 vCPU per instance
  - Options: 1, 2, 4, 6, 8
- `--memory 512Mi`: 512MB RAM per instance
  - Options: 128Mi to 32Gi
  - FastAPI apps typically need 256Mi-512Mi

**Scaling:**
- `--min-instances 0`: Scale to zero when idle (saves money)
  - Use `1` or higher to avoid cold starts (costs more)
- `--max-instances 10`: Maximum concurrent instances
  - Prevents runaway costs from traffic spikes
- `--concurrency 80`: Requests per instance
  - Default 80 is good for most APIs
  - Lower for CPU-heavy operations

**Timeouts:**
- `--timeout 300`: Request timeout in seconds (5 minutes)
  - Maximum allowed: 3600 (1 hour)

**Environment Variables:**
- `--set-env-vars`: Set multiple environment variables
  - Format: `KEY1=value1,KEY2=value2`

**Deployment takes 30-60 seconds.**

**Expected output:**
```
Deploying container to Cloud Run service [fastapi-service]...
✓ Deploying... Done.
  ✓ Creating Revision...
  ✓ Routing traffic...
Done.
Service [fastapi-service] revision [fastapi-service-00001] has been deployed.
Service URL: https://fastapi-service-abc123-uc.a.run.app
```

### Step 8: Test Your Deployment

**Get the service URL:**
```bash
SERVICE_URL=$(gcloud run services describe fastapi-service \
    --region us-central1 \
    --format 'value(status.url)')

echo $SERVICE_URL
```

**Test endpoints:**

```bash
# Health check
curl $SERVICE_URL/

# API health endpoint
curl $SERVICE_URL/api/health

# Hello endpoint
curl $SERVICE_URL/api/hello

# Personalized greeting
curl $SERVICE_URL/api/hello/CloudRun
```

**Test in browser:**

Visit `https://your-service-url.run.app/api/docs` to see the interactive API documentation.

**Verify environment:**
```bash
curl $SERVICE_URL/
```

Should show `"environment": "production"` and `"debug": false`.

## Understanding What Happened

### Container Instance Lifecycle

```
Deployment:
  1. Cloud Run pulls your container image
  2. Starts an instance to verify it works
  3. Assigns a public HTTPS URL
  4. Routes traffic to your instance

When no traffic:
  ↓
  Cloud Run scales to 0 instances
  ↓
  No charges (except storage)

When request arrives:
  ↓
  Cold start (1-2 seconds)
  ↓
  Instance processes request
  ↓
  Instance stays warm for ~15 minutes

When traffic increases:
  ↓
  Cloud Run starts more instances
  ↓
  Up to max-instances limit
  ↓
  Load balanced automatically

When traffic drops:
  ↓
  Instances gradually scale down
  ↓
  Eventually back to min-instances
```

### Revisions

Cloud Run uses **revisions** for deployments:

- Each deployment creates a new revision
- Revisions are immutable (can't be changed)
- Traffic can be split between revisions
- Old revisions can be rolled back to

**View revisions:**
```bash
gcloud run revisions list --service fastapi-service --region us-central1
```

### URLs and Domains

Cloud Run provides:
- **Automatic URL**: `https://SERVICE-NAME-HASH-REGION.a.run.app`
- **HTTPS**: SSL certificate included and auto-renewed
- **Custom domains**: Map your own domain (example.com)

## Managing Environment Variables

### Set new variables:

```bash
gcloud run services update fastapi-service \
    --region us-central1 \
    --set-env-vars "NEW_VAR=value"
```

### Update existing variables:

```bash
gcloud run services update fastapi-service \
    --region us-central1 \
    --update-env-vars "LOG_LEVEL=DEBUG"
```

### Remove variables:

```bash
gcloud run services update fastapi-service \
    --region us-central1 \
    --remove-env-vars "NEW_VAR"
```

### View all variables:

```bash
gcloud run services describe fastapi-service \
    --region us-central1 \
    --format="value(spec.template.spec.containers[0].env)"
```

## Updating Your Deployment

When you make code changes:

### Option 1: Using the Deployment Script

```bash
./scripts/deploy-manual.sh v2
```

This script:
1. Builds new image with tag `v2`
2. Pushes to Artifact Registry
3. Deploys to Cloud Run
4. Verifies deployment

### Option 2: Manual Steps

```bash
# Build new version
docker build -f Dockerfile.prod \
    -t us-central1-docker.pkg.dev/${PROJECT_ID}/fastapi-repo/fastapi:v2 .

# Push
docker push us-central1-docker.pkg.dev/${PROJECT_ID}/fastapi-repo/fastapi:v2

# Deploy
gcloud run deploy fastapi-service \
    --image us-central1-docker.pkg.dev/${PROJECT_ID}/fastapi-repo/fastapi:v2 \
    --region us-central1
```

**Zero-downtime deployment:**
Cloud Run gradually routes traffic from old revision to new revision. Old instances handle existing requests while new instances handle new requests.

## Viewing Logs

### Stream logs in terminal:

```bash
gcloud run services logs tail fastapi-service --region us-central1
```

### View logs in Cloud Console:

1. Visit https://console.cloud.google.com/run
2. Click on `fastapi-service`
3. Click "Logs" tab

**Logs include:**
- Request logs (auto-generated)
- Application logs (from print/logging)
- System logs (container lifecycle)

## Cost Monitoring

### View current month's charges:

1. Visit https://console.cloud.google.com/billing
2. Go to "Reports"
3. Filter by "Cloud Run"

### Set up budget alerts:

1. Go to "Budgets & alerts"
2. Create budget
3. Set amount (e.g., $10/month)
4. Add email notification

### Estimate costs:

**Calculator:** https://cloud.google.com/products/calculator

**Example:** API with 1M requests/month, 512MB memory, 100ms avg response time:
- Requests: 1M * $0.40/M = $0.40
- Memory: (1M requests * 0.1s * 512MB) / 1GB-second * $0.0000025 ≈ $0.13
- Total: ~$0.53/month (well within free tier)

## Troubleshooting

### Deployment fails with "Permission Denied"

**Cause:** APIs not enabled or insufficient permissions.

**Solution:**
```bash
# Re-run setup script
./scripts/setup-gcloud.sh

# Or manually enable APIs
gcloud services enable run.googleapis.com
```

### Container fails to start

**Check logs:**
```bash
gcloud run services logs tail fastapi-service --region us-central1
```

**Common issues:**
- **Port mismatch**: Container must listen on `$PORT` or 8080
- **Missing dependencies**: Check requirements.txt
- **Import errors**: Verify PYTHONPATH in Dockerfile
- **Crashes on startup**: Check for syntax errors

### Service returns 503

**Cause:** Container isn't healthy or crashes after starting.

**Debug:**
1. Check logs for errors
2. Test container locally: `docker run -p 8080:8080 IMAGE`
3. Verify environment variables are correct

### Service returns 404

**Cause:** Endpoint path doesn't match request URL.

**Solution:**
- Check FastAPI route definitions
- Verify API prefix (`/api`)
- Test locally first

### High latency/slow responses

**Causes:**
- Cold starts (if min-instances=0)
- CPU/memory limits too low
- External API calls taking long
- Database queries not optimized

**Solutions:**
- Increase `--min-instances` to 1
- Increase CPU/memory allocation
- Add caching
- Optimize database queries

## Security Best Practices

### 1. Don't Allow Unauthenticated Access for Private APIs

Remove `--allow-unauthenticated`:

```bash
gcloud run deploy fastapi-service \
    --image ... \
    --no-allow-unauthenticated
```

Then use IAM or Identity-Aware Proxy for authentication.

### 2. Set Specific CORS Origins

In production, don't use `CORS_ORIGINS=*`:

```bash
gcloud run services update fastapi-service \
    --region us-central1 \
    --set-env-vars "CORS_ORIGINS=https://yourdomain.com"
```

### 3. Use Secrets for Sensitive Data

Don't put secrets in environment variables. Use Secret Manager:

```bash
# Create secret
echo -n "my-secret-value" | gcloud secrets create my-secret --data-file=-

# Grant access
gcloud secrets add-iam-policy-binding my-secret \
    --member="serviceAccount:SERVICE_ACCOUNT" \
    --role="roles/secretmanager.secretAccessor"

# Mount in Cloud Run
gcloud run services update fastapi-service \
    --region us-central1 \
    --set-secrets="/secrets/my-secret=my-secret:latest"
```

### 4. Limit Ingress

Control what can access your service:

```bash
# Only internal traffic and Cloud Load Balancing
gcloud run services update fastapi-service \
    --region us-central1 \
    --ingress=internal-and-cloud-load-balancing
```

## Next Steps

Congratulations! You've successfully:
- ✅ Understood how Cloud Run works
- ✅ Set up Google Cloud environment
- ✅ Built and pushed a Docker image
- ✅ Deployed to Cloud Run
- ✅ Tested your live deployment

**What you've learned:**
- Serverless container concepts
- Artifact Registry for image storage
- Cloud Run deployment configuration
- Scaling and resource management
- Environment variable management
- Viewing logs and monitoring costs

Continue to [06-cicd-setup.md](./06-cicd-setup.md) to automate this entire process with GitHub Actions!

---

**Additional Resources:**
- Cloud Run documentation: [cloud.google.com/run/docs](https://cloud.google.com/run/docs)
- Artifact Registry: [cloud.google.com/artifact-registry/docs](https://cloud.google.com/artifact-registry/docs)
- Best practices: [cloud.google.com/run/docs/best-practices](https://cloud.google.com/run/docs/best-practices)
