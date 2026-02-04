# Cleanup: Removing Resources

This tutorial shows you how to remove all Google Cloud resources created during these tutorials to avoid ongoing charges.

## Why Cleanup Matters

Even with Cloud Run's "scale to zero" feature, some resources incur storage costs:
- **Artifact Registry**: $0.10/GB/month for stored container images
- **Cloud Storage**: If you used Cloud Build (automatic storage)
- **Service Account Keys**: No cost, but security risk if not managed

**Good news:** Cloud Run services themselves cost $0 when scaled to zero.

## What Resources to Remove

From these tutorials, you created:

1. **Cloud Run Service** (`fastapi-service`)
   - No cost when scaled to zero
   - But good to remove if you're done

2. **Artifact Registry Repository** (`fastapi-repo`)
   - Costs $0.10/GB/month
   - Contains your Docker images

3. **Container Images**
   - Stored in Artifact Registry
   - Each image is ~200-500MB

4. **Service Account** (`github-actions@...`)
   - No cost
   - But has powerful permissions

5. **Service Account Key** (`key.json`)
   - Stored in GitHub Secrets
   - Security risk if compromised

## Quick Cleanup (Automated Script)

We've provided a cleanup script that removes all resources safely.

### Run Cleanup Script

```bash
chmod +x scripts/cleanup.sh
./scripts/cleanup.sh
```

**What it does:**
1. Prompts for confirmation (safety check)
2. Deletes Cloud Run service
3. Deletes Artifact Registry repository
4. Removes local `.gcloud-config` file

**Expected output:**
```
⚠️  Google Cloud Resource Cleanup

Configuration:
  Project ID:    my-project-123
  Region:        us-central1
  Service Name:  fastapi-service
  Repository:    fastapi-repo

═══════════════════════════════════════════════════════════
WARNING: This will permanently delete:
  • Cloud Run service: fastapi-service
  • Artifact Registry repository: fastapi-repo
  • All container images in the repository
═══════════════════════════════════════════════════════════

Are you sure you want to continue? (yes/no): yes

🗑️  Deleting Cloud Run service: fastapi-service
✅ Cloud Run service deleted

🗑️  Deleting Artifact Registry repository: fastapi-repo
✅ Artifact Registry repository deleted

✅ Local configuration file removed

═══════════════════════════════════════════════════════════
Cleanup Complete!
═══════════════════════════════════════════════════════════
```

## Manual Cleanup (Step-by-Step)

If you prefer to remove resources manually or the script fails:

### Step 1: Delete Cloud Run Service

```bash
gcloud run services delete fastapi-service \
    --region us-central1 \
    --quiet
```

**Confirm deletion:**
```bash
gcloud run services list --region us-central1
# Should not show fastapi-service
```

**What this removes:**
- The Cloud Run service
- All revisions
- All configuration

**What this keeps:**
- Container images (still in Artifact Registry)
- Logs (in Cloud Logging for 30 days)

### Step 2: Delete Artifact Registry Repository

**⚠️  Warning:** This permanently deletes all Docker images.

```bash
gcloud artifacts repositories delete fastapi-repo \
    --location us-central1 \
    --quiet
```

**Confirm deletion:**
```bash
gcloud artifacts repositories list --location us-central1
# Should not show fastapi-repo
```

**What this removes:**
- The repository
- ALL container images inside it
- Cannot be undone

### Step 3: (Optional) Delete Service Account

If you're done with CI/CD and won't redeploy:

```bash
# Get service account email
PROJECT_ID=$(gcloud config get-value project)
SA_EMAIL="github-actions@${PROJECT_ID}.iam.gserviceaccount.com"

# Delete service account
gcloud iam service-accounts delete $SA_EMAIL --quiet
```

**Confirm deletion:**
```bash
gcloud iam service-accounts list | grep github-actions
# Should return nothing
```

**⚠️  Warning:** This breaks GitHub Actions workflow. Only do this if you're completely done.

### Step 4: Remove GitHub Secrets

If you deleted the service account, also remove GitHub secrets:

1. Go to your GitHub repository
2. Settings → Secrets and variables → Actions
3. Delete these secrets:
   - `GCP_PROJECT_ID`
   - `GCP_SA_KEY`

### Step 5: Clean Up Local Files

```bash
# Remove configuration file
rm -f .gcloud-config

# Remove service account key (if you still have it)
rm -f key.json

# Verify .gitignore includes these
cat .gitignore | grep -E "\.gcloud-config|key\.json"
```

## Verify Cleanup

### Check Cloud Run Services

```bash
gcloud run services list --region us-central1
```

**Expected:** Empty list or services from other projects.

### Check Artifact Registry

```bash
gcloud artifacts repositories list --location us-central1
```

**Expected:** Empty list or repositories from other projects.

### Check Docker Images Locally

```bash
docker images | grep fastapi
```

**If found, remove:**
```bash
# Remove images
docker rmi us-central1-docker.pkg.dev/${PROJECT_ID}/fastapi-repo/fastapi:v1
docker rmi us-central1-docker.pkg.dev/${PROJECT_ID}/fastapi-repo/fastapi:latest

# Remove all unused images, containers, networks
docker system prune -a
```

## What About APIs?

APIs (Cloud Run, Artifact Registry, etc.) remain enabled but don't cost money unless used.

**Disable APIs (optional):**
```bash
gcloud services disable run.googleapis.com
gcloud services disable artifactregistry.googleapis.com
```

**⚠️  Warning:**
- Disabling takes 30 days to fully remove data
- Cannot re-enable for 30 days
- Other projects in same organization may be affected

**Recommendation:** Leave APIs enabled. They only cost money when actually used.

## What About Logs?

Cloud Logging retains logs for 30 days by default.

**View retention settings:**
```bash
gcloud logging buckets describe _Default --location=global
```

**Logs automatically expire after 30 days.** No action needed.

**If you want to delete logs immediately:**
```bash
# Delete all Cloud Run logs
gcloud logging logs delete projects/${PROJECT_ID}/logs/run.googleapis.com%2Fstderr
gcloud logging logs delete projects/${PROJECT_ID}/logs/run.googleapis.com%2Fstdout
```

## What About the GitHub Repository?

Your code repository stays intact. Only cloud resources are removed.

**Keep the repository to:**
- Reference the code
- Redeploy in the future
- Learn from the examples

## Cost Verification

### Check Current Billing

1. Go to https://console.cloud.google.com/billing
2. Select "Reports"
3. Filter by "Cloud Run" and "Artifact Registry"
4. Verify costs drop to $0

**Allow 24-48 hours for usage data to appear.**

### Set Up Final Budget Alert

Even after cleanup, set a budget alert to catch unexpected charges:

```bash
# Check if budget exists
gcloud billing budgets list --billing-account=BILLING_ACCOUNT_ID

# Create budget if needed (via Cloud Console)
# Billing → Budgets & alerts → Create budget
```

**Recommended:** $1/month budget with 100% alert.

## If You Want to Redeploy Later

### Option 1: Keep Everything

Instead of deleting resources, just ensure they're scaled to zero:

```bash
# Verify min-instances is 0
gcloud run services describe fastapi-service \
    --region us-central1 \
    --format='value(spec.template.spec.containerConcurrency,spec.template.metadata.annotations.autoscaling.knative.dev/minScale)'
```

**Cost:** Only Artifact Registry storage (~$0.10/month for 1GB)

### Option 2: Delete and Recreate

If you delete everything:

```bash
# Later, to redeploy:
./scripts/setup-gcloud.sh
./scripts/deploy-manual.sh
```

**Time to redeploy:** ~10 minutes

## Common Cleanup Issues

### "Service does not exist"

**Cause:** Service already deleted or wrong region/name

**Solution:** No action needed, service is gone

### "Repository does not exist"

**Cause:** Repository already deleted or wrong location/name

**Solution:** No action needed, repository is gone

### "Permission denied"

**Cause:** Insufficient permissions to delete resources

**Solution:**
```bash
# Check your permissions
gcloud projects get-iam-policy $(gcloud config get-value project) \
    --flatten="bindings[].members" \
    --filter="bindings.members:user:YOUR_EMAIL"

# You need: roles/owner or roles/editor or specific delete permissions
```

### Cannot Delete Service Account (In Use)

**Cause:** Service account still bound to resources

**Solution:**
```bash
# Find resources using the service account
gcloud projects get-iam-policy $(gcloud config get-value project) \
    --flatten="bindings[].members" \
    --filter="bindings.members:serviceAccount:SA_EMAIL"

# Remove bindings first, then delete
```

## Cleanup Checklist

Before considering cleanup complete, verify:

- [ ] Cloud Run service deleted
- [ ] Artifact Registry repository deleted
- [ ] Service account deleted (if desired)
- [ ] GitHub secrets removed (if service account deleted)
- [ ] Local `.gcloud-config` removed
- [ ] Local `key.json` removed
- [ ] Docker images removed locally
- [ ] Verified $0 charges in billing console (after 24-48 hours)

## Final Cost Summary

After cleanup, you should have:

- **Cloud Run costs**: $0
- **Artifact Registry costs**: $0
- **Other costs**: $0
- **Total**: $0/month

**Exceptions:**
- If you kept logs longer than 30 days (custom retention)
- If you enabled other services during exploration
- If you have other resources in the project

## What You Learned

Through these tutorials, you:

✅ **Deployed a production FastAPI app to Cloud Run**
✅ **Set up automated CI/CD with GitHub Actions**
✅ **Configured monitoring and logging**
✅ **Understood serverless container concepts**
✅ **Learned cloud security best practices**
✅ **Managed costs effectively**

## Next Steps

### Keep Learning

**Explore other cloud platforms:**
- Azure Container Apps: Checkout `azure` branch
- AWS App Runner: Similar serverless container service

**Enhance this project:**
- Add database (Cloud SQL, Firestore)
- Add authentication (Firebase Auth, Auth0)
- Add caching (Cloud Memorystore)
- Add custom domain
- Add monitoring dashboard

**Build something new:**
Take what you learned and build your own project!

### Stay Connected

- Star this repository on GitHub
- Share with others learning cloud deployment
- Contribute improvements via pull requests

## Thank You!

Thank you for completing this tutorial series. You now have the skills to deploy production-ready applications to the cloud with confidence.

**Happy coding!** 🚀

---

**Resources:**
- This repository: [GitHub](../../)
- Google Cloud documentation: [cloud.google.com/docs](https://cloud.google.com/docs)
- FastAPI documentation: [fastapi.tiangolo.com](https://fastapi.tiangolo.com/)
- Join the discussion: [GitHub Discussions](../../discussions)
