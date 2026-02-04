# CI/CD Setup: Automating Deployments with GitHub Actions

This tutorial shows you how to automate testing and deployment using GitHub Actions.

## What is CI/CD?

**CI/CD** stands for Continuous Integration / Continuous Deployment:

**Continuous Integration (CI):**
- Automatically test code changes
- Catch bugs early
- Ensure code quality

**Continuous Deployment (CD):**
- Automatically deploy passing code
- No manual deployment steps
- Fast, reliable releases

### Benefits

**Without CI/CD:**
```
1. Write code
2. Manually run tests
3. Manually build Docker image
4. Manually push to registry
5. Manually deploy to Cloud Run
6. Hope nothing broke
```

**With CI/CD:**
```
1. Write code
2. Push to GitHub
3. Everything else happens automatically ✨
```

### Our CI/CD Pipeline

```
┌──────────┐     ┌─────────────┐     ┌──────────┐     ┌───────────┐
│   Push   │────▶│  Run Tests  │────▶│  Build   │────▶│  Deploy   │
│ to GitHub│     │   (pytest)  │     │  Docker  │     │ Cloud Run │
└──────────┘     └─────────────┘     └──────────┘     └───────────┘
                        │                                     │
                        │ If tests fail                       │
                        ▼                                     ▼
                   ❌ Stop                                ✅ Live
```

## Understanding GitHub Actions

### What is GitHub Actions?

A CI/CD platform integrated into GitHub that runs workflows automatically based on events (pushes, PRs, schedules).

**Key concepts:**

- **Workflow**: Automated process defined in YAML
- **Job**: Set of steps that run on the same runner
- **Step**: Individual task (run command, use action)
- **Runner**: Server that executes your workflows (GitHub-hosted or self-hosted)
- **Action**: Reusable unit of code (like a function)

### Workflow File Location

Workflows live in `.github/workflows/` directory:

```
.github/
└── workflows/
    ├── test.yaml    # Runs on main branch (testing only)
    └── deploy.yaml  # Runs on gcloud branch (testing + deployment)
```

## Understanding Our Workflow

Let's examine `.github/workflows/deploy.yaml` section by section.

### Workflow Name and Triggers

```yaml
name: Deploy to Google Cloud Run

on:
  push:
    branches: [ gcloud ]
    paths-ignore:
      - 'docs/**'
      - 'scripts/**'
      - '*.md'
  workflow_dispatch:
```

**Breakdown:**
- `name`: Shows up in GitHub Actions UI
- `on.push.branches`: Triggers when pushing to `gcloud` branch
- `paths-ignore`: Doesn't run for documentation-only changes
- `workflow_dispatch`: Allows manual triggering from GitHub UI

### Environment Variables

```yaml
env:
  PROJECT_ID: ${{ secrets.GCP_PROJECT_ID }}
  REGION: us-central1
  SERVICE_NAME: fastapi-service
  REGISTRY: us-central1-docker.pkg.dev
  REPOSITORY: fastapi-repo
  IMAGE_NAME: fastapi
```

**Why use env vars?**
- Single source of truth
- Easy to update (change once, used everywhere)
- Cleaner workflow file

**Secrets:** `${{ secrets.NAME }}` accesses GitHub secrets (secure values).

### Test Job

```yaml
jobs:
  test:
    name: Run Tests
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: '3.12'
          cache: 'pip'
      - run: pip install -r requirements.txt && pip install -r requirements-dev.txt
      - run: ruff check src/
      - run: pytest src/tests/ -v --cov=src
```

**What happens:**
1. **Checkout code**: Downloads your repository
2. **Setup Python**: Installs Python 3.12 with pip caching
3. **Install dependencies**: requirements.txt and requirements-dev.txt
4. **Lint**: Check code style with ruff
5. **Test**: Run pytest with coverage

### Deploy Job

```yaml
  deploy:
    name: Build and Deploy to Cloud Run
    needs: test  # Only runs if test job succeeds
    runs-on: ubuntu-latest
    if: github.event_name == 'push'  # Skip on PRs

    permissions:
      contents: read
      id-token: write  # For Workload Identity Federation

    steps:
      # ... deployment steps ...
```

**Key points:**
- `needs: test`: Deploy only if tests pass
- `if: github.event_name == 'push'`: Don't deploy on pull requests
- `permissions`: Required for authentication

### Authentication Step

```yaml
      - name: Authenticate to Google Cloud
        uses: google-github-actions/auth@v2
        with:
          credentials_json: ${{ secrets.GCP_SA_KEY }}
```

**What this does:**
Uses a service account key to authenticate with Google Cloud.

**Two authentication methods:**

**Method 1: Service Account Key (we use this)**
- Create service account
- Generate JSON key
- Store key in GitHub secrets

**Method 2: Workload Identity Federation (more secure)**
- No key to manage
- Temporary credentials
- Requires more setup

### Build and Push Steps

```yaml
      - name: Configure Docker for Artifact Registry
        run: gcloud auth configure-docker ${{ env.REGISTRY }}

      - name: Build Docker image
        run: |
          docker build -f Dockerfile.prod \
            -t ${{ env.REGISTRY }}/${{ env.PROJECT_ID }}/${{ env.REPOSITORY }}/${{ env.IMAGE_NAME }}:${{ github.sha }} \
            -t ${{ env.REGISTRY }}/${{ env.PROJECT_ID }}/${{ env.REPOSITORY }}/${{ env.IMAGE_NAME }}:latest \
            .

      - name: Push Docker image
        run: |
          docker push ${{ env.REGISTRY }}/${{ env.PROJECT_ID }}/${{ env.REPOSITORY }}/${{ env.IMAGE_NAME }}:${{ github.sha }}
          docker push ${{ env.REGISTRY }}/${{ env.PROJECT_ID }}/${{ env.REPOSITORY }}/${{ env.IMAGE_NAME }}:latest
```

**Image tagging strategy:**
- `${{ github.sha }}`: Git commit hash (e.g., `abc123...`)
- `latest`: Always points to most recent build

**Why two tags?**
- `sha`: Track exact commit deployed
- `latest`: Easy reference to current version

### Deploy Step

```yaml
      - name: Deploy to Cloud Run
        run: |
          gcloud run deploy ${{ env.SERVICE_NAME }} \
            --image ${{ env.REGISTRY }}/${{ env.PROJECT_ID }}/${{ env.REPOSITORY }}/${{ env.IMAGE_NAME }}:${{ github.sha }} \
            --region ${{ env.REGION }} \
            --platform managed \
            --allow-unauthenticated \
            --port 8080 \
            --cpu 1 \
            --memory 512Mi \
            --min-instances 0 \
            --max-instances 10 \
            --set-env-vars "ENVIRONMENT=production,DEBUG=false" \
            --quiet
```

**Same as manual deployment**, but automated!

### Verification Steps

```yaml
      - name: Get Service URL
        id: url
        run: |
          SERVICE_URL=$(gcloud run services describe ...)
          echo "url=$SERVICE_URL" >> $GITHUB_OUTPUT

      - name: Verify Deployment
        run: |
          sleep 10
          curl -f ${{ steps.url.outputs.url }}/ || exit 1
```

**What this does:**
1. Gets deployed service URL
2. Waits 10 seconds for service to be ready
3. Makes HTTP request to verify
4. Fails workflow if service doesn't respond

## Setting Up GitHub Secrets

GitHub secrets store sensitive values (API keys, credentials) securely.

### Create Service Account

A service account is an identity for applications (not humans).

**Step 1: Create service account**

```bash
# Set variables
PROJECT_ID=$(gcloud config get-value project)
SA_NAME="github-actions"
SA_EMAIL="${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

# Create service account
gcloud iam service-accounts create $SA_NAME \
    --description="Service account for GitHub Actions deployments" \
    --display-name="GitHub Actions"
```

**Step 2: Grant permissions**

```bash
# Cloud Run Admin (deploy services)
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:${SA_EMAIL}" \
    --role="roles/run.admin"

# Artifact Registry Writer (push images)
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:${SA_EMAIL}" \
    --role="roles/artifactregistry.writer"

# Service Account User (act as service account)
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:${SA_EMAIL}" \
    --role="roles/iam.serviceAccountUser"

# Storage Admin (for Cloud Build cache)
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:${SA_EMAIL}" \
    --role="roles/storage.admin"
```

**Step 3: Generate key**

```bash
gcloud iam service-accounts keys create key.json \
    --iam-account=$SA_EMAIL
```

**⚠️  Security:** This key file grants full access to your project. Keep it secure!

### Add Secrets to GitHub

**Step 1: Open repository settings**
1. Go to your GitHub repository
2. Click "Settings" tab
3. Click "Secrets and variables" → "Actions"

**Step 2: Add secrets**

Click "New repository secret" and add:

**Secret 1: GCP_PROJECT_ID**
- Name: `GCP_PROJECT_ID`
- Value: Your project ID (e.g., `my-project-12345`)

**Secret 2: GCP_SA_KEY**
- Name: `GCP_SA_KEY`
- Value: Contents of `key.json` file

```bash
# View key contents (copy this to GitHub)
cat key.json
```

**Step 3: Verify secrets**

After adding, you should see:
- `GCP_PROJECT_ID`
- `GCP_SA_KEY`

**Important:** You won't be able to view secret values again. They're encrypted.

### Clean Up Key File

```bash
# Delete local copy (it's now in GitHub secrets)
rm key.json

# Ensure it's in .gitignore
echo "key.json" >> .gitignore
```

**Never commit key files to git!**

## Triggering the Workflow

### Automatic Trigger (Push)

Simply push to the gcloud branch:

```bash
# Make a change
echo "# Update" >> README.md

# Commit
git add README.md
git commit -m "Test CI/CD pipeline"

# Push to trigger workflow
git push origin gcloud
```

### Manual Trigger

1. Go to your GitHub repository
2. Click "Actions" tab
3. Click "Deploy to Google Cloud Run" workflow
4. Click "Run workflow" button
5. Select branch and click "Run workflow"

## Monitoring the Workflow

### View Running Workflow

1. Go to "Actions" tab on GitHub
2. Click on the running workflow
3. Click on job ("Run Tests" or "Build and Deploy")
4. Watch real-time logs

### Workflow States

**Icons:**
- 🟡 Yellow circle: In progress
- ✅ Green check: Success
- ❌ Red X: Failed
- ⏭️  Gray: Skipped

### Check Deployment Status

After workflow completes:

```bash
# Get service URL
gcloud run services describe fastapi-service \
    --region us-central1 \
    --format='value(status.url)'

# Test it
curl <service-url>/api/health
```

## Understanding Build Failures

### Test Failures

**Scenario:** Tests fail on GitHub but pass locally

**Common causes:**
1. **Environment differences**: Missing environment variables
2. **Dependencies**: requirements.txt out of sync
3. **Caching**: Old cached dependencies

**Debug:**
- Check test job logs in GitHub Actions
- Look for assertion errors or import errors
- Run tests locally with same Python version (3.12)

### Deployment Failures

**Scenario:** Tests pass but deployment fails

**Common causes:**
1. **Permission errors**: Service account lacks necessary roles
2. **Quota exceeded**: Too many requests to APIs
3. **Invalid configuration**: Wrong project ID or region

**Debug:**
- Check "Deploy to Cloud Run" step logs
- Verify secrets are set correctly
- Check service account has correct permissions

### Verification Failures

**Scenario:** Deployment succeeds but verification fails

**Common causes:**
1. **Service not ready**: Need longer wait time (increase `sleep`)
2. **Application error**: Container starts but crashes
3. **Wrong URL**: Typo in service name

**Debug:**
```bash
# Check Cloud Run logs
gcloud run services logs tail fastapi-service --region us-central1
```

## Workflow Best Practices

### 1. Use Caching

Our workflow uses pip caching:

```yaml
- uses: actions/setup-python@v5
  with:
    python-version: '3.12'
    cache: 'pip'  # Caches pip dependencies
```

**Benefit:** Faster builds (30s vs 2min)

### 2. Fail Fast

```yaml
- run: ruff check src/
- run: pytest src/tests/ -v
```

Linting runs before tests. If code style is wrong, don't waste time running tests.

### 3. Matrix Testing (Optional)

Test multiple Python versions:

```yaml
strategy:
  matrix:
    python-version: ['3.11', '3.12']

steps:
  - uses: actions/setup-python@v5
    with:
      python-version: ${{ matrix.python-version }}
```

### 4. Conditional Steps

Only deploy on push (not PRs):

```yaml
if: github.event_name == 'push'
```

### 5. Pull Request Comments

Add this step to comment deployment URL on PRs:

```yaml
- name: Comment URL on PR
  if: github.event_name == 'pull_request'
  uses: actions/github-script@v7
  with:
    script: |
      github.rest.issues.createComment({
        issue_number: context.issue.number,
        owner: context.repo.owner,
        repo: context.repo.repo,
        body: `🚀 Deployed to: ${{ steps.url.outputs.url }}`
      })
```

## Cost Considerations

### GitHub Actions Minutes

**Free tier:**
- Public repos: Unlimited
- Private repos: 2,000 minutes/month

**Our workflow:**
- ~5 minutes per run
- ~400 runs per month on free tier

**Optimize:**
- Use caching
- Skip workflows for docs-only changes
- Use `paths-ignore` directive

### Google Cloud Costs

CI/CD adds minimal costs:
- Artifact Registry: $0.10/GB/month storage
- Cloud Run: Only charged when serving requests
- Cloud Build: 120 build-minutes/day free

**Typical cost:** $1-2/month for active development

## Security Best Practices

### 1. Minimal Service Account Permissions

Only grant necessary roles. Don't use Owner or Editor roles.

### 2. Rotate Keys Regularly

```bash
# Create new key
gcloud iam service-accounts keys create new-key.json \
    --iam-account=$SA_EMAIL

# Update GitHub secret with new key

# Delete old key
gcloud iam service-accounts keys list \
    --iam-account=$SA_EMAIL

gcloud iam service-accounts keys delete KEY_ID \
    --iam-account=$SA_EMAIL
```

### 3. Use Environment-Specific Service Accounts

Create separate service accounts for:
- Development
- Staging
- Production

### 4. Enable Audit Logging

Track what your service account does:

1. Go to IAM & Admin → Audit Logs
2. Enable "Data Read" and "Data Write" for Cloud Run
3. Review logs periodically

## Troubleshooting

### "Failed to authenticate to Google Cloud"

**Cause:** Invalid or missing service account key

**Solution:**
1. Verify `GCP_SA_KEY` secret exists
2. Check key.json contents (should be valid JSON)
3. Regenerate key if needed

### "Permission denied" during deployment

**Cause:** Service account lacks necessary roles

**Solution:**
```bash
# Re-grant permissions
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:${SA_EMAIL}" \
    --role="roles/run.admin"
```

### Workflow doesn't trigger

**Causes:**
- Pushed to wrong branch
- Workflow file has syntax errors
- Only changed ignored paths

**Solution:**
- Verify you're on `gcloud` branch: `git branch`
- Check workflow syntax: https://rhysd.github.io/actionlint/
- Make a non-docs change

## Next Steps

Congratulations! You've set up automated CI/CD:
- ✅ Tests run automatically on every push
- ✅ Deployments happen automatically when tests pass
- ✅ Secure authentication with service accounts
- ✅ Workflow monitoring and debugging

**What you've learned:**
- GitHub Actions concepts and workflows
- Service account creation and management
- Secure secret management
- CI/CD best practices
- Debugging failed workflows

Continue to [07-monitoring.md](./07-monitoring.md) to learn about monitoring and debugging your deployed application.

---

**Additional Resources:**
- GitHub Actions documentation: [docs.github.com/actions](https://docs.github.com/actions)
- google-github-actions/auth: [github.com/google-github-actions/auth](https://github.com/google-github-actions/auth)
- Service accounts best practices: [cloud.google.com/iam/docs/best-practices-service-accounts](https://cloud.google.com/iam/docs/best-practices-service-accounts)
