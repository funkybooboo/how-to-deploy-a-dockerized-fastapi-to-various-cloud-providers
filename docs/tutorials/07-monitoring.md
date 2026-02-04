# Monitoring and Debugging: Production Observability

This tutorial covers monitoring, logging, and debugging your deployed FastAPI application on Cloud Run.

## Why Monitoring Matters

In production, you need to know:
- Is my service up and responding?
- How many requests are being processed?
- Are there any errors?
- How much is it costing?
- Is performance acceptable?

Without monitoring, you're flying blind.

## Cloud Run Metrics

### Access Metrics Dashboard

**Via Cloud Console:**
1. Go to https://console.cloud.google.com/run
2. Click on `fastapi-service`
3. Click "Metrics" tab

**Via CLI:**
```bash
# Open metrics in browser
gcloud run services describe fastapi-service \
    --region us-central1 \
    --format='value(status.url)' | \
    xargs -I {} open "https://console.cloud.google.com/run/detail/us-central1/fastapi-service/metrics"
```

### Key Metrics

#### Request Count
**What it shows:** Number of requests over time

**Why it matters:**
- Understand traffic patterns
- Identify traffic spikes
- Verify deployment impact

**Typical values:**
- Low traffic: 10-100 requests/day
- Medium traffic: 1,000-10,000 requests/day
- High traffic: 100,000+ requests/day

#### Request Latency
**What it shows:** Time to process requests (P50, P95, P99)

**Why it matters:**
- User experience (slow = bad UX)
- Identify performance issues
- Compare before/after deployments

**Percentiles explained:**
- P50 (median): 50% of requests faster than this
- P95: 95% of requests faster than this
- P99: 99% of requests faster than this

**Good targets:**
- P50 < 100ms: Excellent
- P95 < 500ms: Good
- P99 < 1000ms: Acceptable

**High latency causes:**
- Cold starts (P99 spikes)
- External API calls
- Database queries
- Insufficient resources

#### Container Instance Count
**What it shows:** Number of running container instances

**Why it matters:**
- Understand scaling behavior
- Verify auto-scaling works
- Identify cost drivers

**Typical patterns:**
- Off-hours: 0 instances (scaled to zero)
- Normal traffic: 1-3 instances
- Traffic spike: Scales up to max-instances

#### Billable Container Instance Time
**What it shows:** Time instances spend processing requests

**Why it matters:** This is what you pay for!

**Formula:**
```
Cost = (Instances × Time × Memory) + (Requests × Cost per Request)
```

**Reduce costs by:**
- Scaling to zero when idle (min-instances=0)
- Using appropriate memory limits (don't over-provision)
- Optimizing response times (faster = cheaper)

#### Error Rate
**What it shows:** Percentage of requests that fail (4xx, 5xx)

**Why it matters:**
- Service health indicator
- User impact measurement
- Alert trigger

**HTTP status codes:**
- 2xx: Success
- 4xx: Client error (bad request, not found, etc.)
- 5xx: Server error (your code crashed)

**Good target:** < 1% error rate

## Cloud Logging

### View Logs

**Via Cloud Console:**
1. Go to https://console.cloud.google.com/run
2. Click on `fastapi-service`
3. Click "Logs" tab

**Via CLI (recommended for debugging):**

Stream logs in real-time:
```bash
gcloud run services logs tail fastapi-service --region us-central1
```

View recent logs:
```bash
gcloud run services logs read fastapi-service \
    --region us-central1 \
    --limit 50
```

### Log Types

#### Request Logs (Auto-generated)

Cloud Run automatically logs every HTTP request:

```json
{
  "httpRequest": {
    "requestMethod": "GET",
    "requestUrl": "/api/hello",
    "status": 200,
    "responseSize": "45",
    "latency": "0.123s",
    "userAgent": "curl/7.79.1"
  },
  "timestamp": "2024-01-15T10:30:45.123Z"
}
```

**Contains:**
- HTTP method, URL, status code
- Response size and latency
- User agent and IP address
- Timestamp

#### Application Logs

Your code's print/logging output:

```python
# This appears in logs
print("Processing request for user:", user_id)

# Better: use logging module
import logging
logging.info(f"Processing request for user: {user_id}")
```

#### System Logs

Container lifecycle events:
- Container started
- Container terminated
- Scaling events
- Health checks

### Log Filtering

**Filter by severity:**
```bash
# Errors only
gcloud run services logs read fastapi-service \
    --region us-central1 \
    --filter='severity>=ERROR'

# Warnings and errors
gcloud run services logs read fastapi-service \
    --region us-central1 \
    --filter='severity>=WARNING'
```

**Filter by time:**
```bash
# Last hour
gcloud run services logs read fastapi-service \
    --region us-central1 \
    --filter='timestamp>="2024-01-15T10:00:00Z"'

# Specific time range
gcloud run services logs read fastapi-service \
    --region us-central1 \
    --filter='timestamp>="2024-01-15T10:00:00Z" AND timestamp<="2024-01-15T11:00:00Z"'
```

**Filter by HTTP status:**
```bash
# 500 errors
gcloud run services logs read fastapi-service \
    --region us-central1 \
    --filter='httpRequest.status>=500'

# 404 errors
gcloud run services logs read fastapi-service \
    --region us-central1 \
    --filter='httpRequest.status=404'
```

**Combine filters:**
```bash
# 500 errors in last hour
gcloud run services logs read fastapi-service \
    --region us-central1 \
    --filter='httpRequest.status>=500 AND timestamp>="2024-01-15T10:00:00Z"' \
    --limit 100
```

### Structured Logging

**Why structured logging?**
- Easier to filter and search
- Better for automated analysis
- Standard format (JSON)

**Update your application:**

```python
import logging
import json

# Configure structured logging
logging.basicConfig(
    level=logging.INFO,
    format='%(message)s'
)

def log_structured(message, **kwargs):
    """Log structured JSON for Cloud Logging."""
    log_entry = {
        "message": message,
        "severity": kwargs.get("severity", "INFO"),
        **kwargs
    }
    print(json.dumps(log_entry))

# Usage
log_structured(
    "User login",
    severity="INFO",
    user_id=123,
    ip_address="192.168.1.1"
)
```

**Benefit:** Can filter by custom fields in Cloud Console.

## Error Tracking

### Cloud Error Reporting

Cloud Run integrates with Error Reporting to aggregate errors.

**Access:**
1. Go to https://console.cloud.google.com/errors
2. Select "Cloud Run" service
3. View grouped errors

**Features:**
- Groups similar errors
- Shows frequency and first/last occurrence
- Links to stack traces
- Email notifications

**Enable:**
```bash
gcloud services enable clouderrorreporting.googleapis.com
```

### Common Errors and Solutions

#### Import Error

**Log:**
```
ModuleNotFoundError: No module named 'fastapi'
```

**Cause:** Missing dependency in requirements.txt

**Solution:**
1. Add to requirements.txt
2. Rebuild and redeploy

#### Port Mismatch

**Log:**
```
Cloud Run error: Container failed to start. Failed to start and listen on the port defined by the PORT environment variable.
```

**Cause:** Container listening on wrong port

**Solution:**
Ensure Dockerfile runs uvicorn on $PORT:
```dockerfile
CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8080"]
```

#### Memory Limit Exceeded

**Log:**
```
Memory limit of 512Mi exceeded.
```

**Cause:** Application using too much memory

**Solution:**
```bash
# Increase memory limit
gcloud run services update fastapi-service \
    --region us-central1 \
    --memory 1Gi
```

#### Timeout

**Log:**
```
Request timeout (deadline exceeded)
```

**Cause:** Request took longer than timeout setting

**Solution:**
```bash
# Increase timeout
gcloud run services update fastapi-service \
    --region us-central1 \
    --timeout 600  # 10 minutes
```

## Performance Monitoring

### Identify Slow Endpoints

**Using logs:**
```bash
# Find requests > 1 second
gcloud run services logs read fastapi-service \
    --region us-central1 \
    --filter='httpRequest.latency>1s' \
    --format='table(timestamp, httpRequest.requestUrl, httpRequest.latency)'
```

**Analyze patterns:**
- Which endpoints are slowest?
- Is it consistent or occasional?
- Does it correlate with specific times?

### Add Request Tracing

Add timing information to your application:

```python
import time
from fastapi import Request

@app.middleware("http")
async def add_process_time_header(request: Request, call_next):
    start_time = time.time()
    response = await call_next(request)
    process_time = time.time() - start_time
    response.headers["X-Process-Time"] = str(process_time)

    # Log slow requests
    if process_time > 1.0:
        logging.warning(
            f"Slow request: {request.url.path} took {process_time:.2f}s"
        )

    return response
```

### Cold Start Monitoring

**Identify cold starts in logs:**
```bash
gcloud run services logs read fastapi-service \
    --region us-central1 \
    --filter='textPayload:"Container called exit"'
```

**Reduce cold starts:**
1. Keep container image small
2. Minimize startup time
3. Use min-instances > 0 (costs more)

## Alerting

### Create Alert Policy

**Via Cloud Console:**
1. Go to Monitoring → Alerting
2. Click "Create Policy"
3. Add condition (e.g., "Error rate > 5%")
4. Add notification channel (email, SMS, Slack)
5. Save policy

**Via CLI:**
```bash
# Create email notification channel
gcloud alpha monitoring channels create \
    --display-name="Email Alerts" \
    --type=email \
    --channel-labels=email_address=you@example.com

# Create alert for high error rate
gcloud alpha monitoring policies create \
    --notification-channels=CHANNEL_ID \
    --display-name="High Error Rate" \
    --condition-display-name="Error rate > 5%" \
    --condition-threshold-value=5 \
    --condition-threshold-duration=300s
```

### Alert Best Practices

**Alert on:**
- Error rate > 5%
- Latency P99 > 2 seconds
- No requests for > 1 hour (if you expect traffic)
- Budget exceeds threshold

**Don't alert on:**
- Individual errors (too noisy)
- Normal traffic patterns
- Expected maintenance windows

**Good alert example:**
```
Alert: High Error Rate
Condition: Error rate > 5% for 5 minutes
Action: Email on-call engineer
Runbook: https://docs.example.com/runbooks/high-error-rate
```

## Debugging Production Issues

### Step 1: Check Recent Changes

**View deployment history:**
```bash
gcloud run revisions list \
    --service fastapi-service \
    --region us-central1
```

**If issue started after recent deployment:**
```bash
# Rollback to previous revision
gcloud run services update-traffic fastapi-service \
    --region us-central1 \
    --to-revisions=PREVIOUS_REVISION=100
```

### Step 2: Check Logs for Errors

```bash
# Recent errors
gcloud run services logs read fastapi-service \
    --region us-central1 \
    --filter='severity>=ERROR' \
    --limit 50
```

### Step 3: Check Resource Usage

**Via Cloud Console:**
1. Go to Cloud Run service
2. Check "Metrics" tab
3. Look at memory and CPU utilization

**If near limits:**
```bash
# Increase resources
gcloud run services update fastapi-service \
    --region us-central1 \
    --memory 1Gi \
    --cpu 2
```

### Step 4: Test Endpoints

```bash
# Get service URL
SERVICE_URL=$(gcloud run services describe fastapi-service \
    --region us-central1 \
    --format='value(status.url)')

# Test health
curl -v $SERVICE_URL/api/health

# Check response headers
curl -I $SERVICE_URL/

# Test with different methods
curl -X POST $SERVICE_URL/api/endpoint -d '{"data":"test"}'
```

### Step 5: Compare with Local

```bash
# Run locally with production config
export ENVIRONMENT=production
export DEBUG=false
uvicorn src.main:app --host 0.0.0.0 --port 8080
```

If works locally but not in Cloud Run → environment issue

## Cost Monitoring

### View Current Costs

**Via Cloud Console:**
1. Go to Billing → Reports
2. Filter by "Cloud Run"
3. Select time period

**Set up budget alerts:**
1. Go to Billing → Budgets & alerts
2. Create budget (e.g., $10/month)
3. Set alert thresholds (50%, 90%, 100%)
4. Add email notification

### Cost Breakdown

**Request costs:**
```
Requests per month × $0.40 per million = Request cost
```

**Compute costs:**
```
(Total GB-seconds × $0.00001800) + (Total vCPU-seconds × $0.00002400) = Compute cost
```

**Example calculation:**
- 1M requests/month
- 200ms average response time
- 512MB memory, 1 vCPU

```
Request cost: 1M × $0.40/M = $0.40
Memory: (1M × 0.2s × 0.5GB) × $0.00001800 = $1.80
CPU: (1M × 0.2s × 1vCPU) × $0.00002400 = $4.80
Total: ~$7/month
```

### Reduce Costs

1. **Scale to zero**: Set min-instances=0
2. **Optimize resources**: Don't over-provision memory/CPU
3. **Reduce request time**: Faster responses = lower costs
4. **Cache responses**: Fewer duplicate computations
5. **Use CDN**: Serve static content from edge locations

## Uptime Monitoring

### Cloud Monitoring Uptime Checks

Create uptime check:

```bash
gcloud monitoring uptime-checks create http uptime-check-fastapi \
    --resource-type=uptime-url \
    --host=your-service-url.run.app \
    --http-request-path=/api/health \
    --check-interval=60s
```

**What it does:**
- Checks endpoint every 60 seconds
- Alerts if endpoint down
- Tracks uptime percentage

**View uptime:**
1. Go to Monitoring → Uptime checks
2. View uptime percentage and incidents

## Next Steps

You now know how to:
- ✅ View and interpret Cloud Run metrics
- ✅ Access and filter logs
- ✅ Track errors with Error Reporting
- ✅ Debug production issues
- ✅ Monitor costs
- ✅ Set up alerts
- ✅ Create uptime checks

Continue to [08-cleanup.md](./08-cleanup.md) to learn how to remove all resources and avoid ongoing charges.

---

**Additional Resources:**
- Cloud Monitoring: [cloud.google.com/monitoring/docs](https://cloud.google.com/monitoring/docs)
- Cloud Logging: [cloud.google.com/logging/docs](https://cloud.google.com/logging/docs)
- Error Reporting: [cloud.google.com/error-reporting/docs](https://cloud.google.com/error-reporting/docs)
- Cloud Run observability: [cloud.google.com/run/docs/logging](https://cloud.google.com/run/docs/logging)
