# Deployment Guide

## Prerequisites Checklist

- [ ] Go 1.21+ installed
- [ ] Docker Desktop installed and running
- [ ] Kubernetes enabled in Docker Desktop
- [ ] kubectl configured
- [ ] Git configured with GitHub credentials
- [ ] VS Code installed (optional)

## Initial Setup

### 1. Verify Prerequisites

```bash
# Check Go version
go version

# Check Docker
docker --version
docker ps

# Check Kubernetes
kubectl version
kubectl cluster-info

# Check Git
git --version
git config --list
```

### 2. Initialize Project

```bash
cd /Users/psyunix/Documents/git/claude/golang

# Download dependencies
make deps

# Verify build
make build

# Run tests
make test
```

## Local Development Deployment

### Option 1: Run Directly

```bash
make run
```

Access at: `http://localhost:8080`

### Option 2: Run in Docker

```bash
# Build image
make docker-build

# Run container
make docker-run

# Test
curl http://localhost:8080/health

# Stop when done
make docker-stop
```

## Kubernetes Deployment

### Step 1: Verify Kubernetes Cluster

```bash
# Check cluster status
kubectl cluster-info

# View nodes
kubectl get nodes

# Should show: docker-desktop   Ready
```

### Step 2: Deploy Application

```bash
# Deploy all resources
make k8s-deploy
```

This will:
1. Create `golang-app` namespace
2. Create ConfigMap and Secrets
3. Deploy the application (2 replicas)
4. Create NodePort and LoadBalancer services

### Step 3: Verify Deployment

```bash
# Check all resources
make k8s-status

# Expected output:
# NAME                              READY   STATUS    RESTARTS   AGE
# pod/golang-api-xxxxxxxxxx-xxxxx   1/1     Running   0          1m
# pod/golang-api-xxxxxxxxxx-xxxxx   1/1     Running   0          1m
```

### Step 4: Access the Application

```bash
# Via NodePort (preferred for Docker Desktop)
curl http://localhost:30080/health

# Get all services
curl http://localhost:30080/api/services

# Get specific service
curl http://localhost:30080/api/services/api-server
```

### Step 5: View Logs

```bash
# Follow logs from all pods
make k8s-logs

# Or manually
kubectl logs -f deployment/golang-api -n golang-app
```

### Step 6: Monitor Application

```bash
# Watch pods
kubectl get pods -n golang-app -w

# Describe deployment
kubectl describe deployment golang-api -n golang-app

# View events
kubectl get events -n golang-app --sort-by='.lastTimestamp'
```

## GitHub Setup and CI/CD

### Step 1: Create GitHub Repository

```bash
# Initialize Git (if not already done)
cd /Users/psyunix/Documents/git/claude/golang
git init
git add .
git commit -m "Initial commit: Go API with Docker and Kubernetes"

# Create repository on GitHub
# Go to: https://github.com/new
# Repository name: golang
# Public or Private: Your choice
# DO NOT initialize with README (we already have one)

# Add remote and push
git branch -M main
git remote add origin https://github.com/psyunix/golang.git
git push -u origin main
```

### Step 2: Configure GitHub Secrets

No additional secrets needed! The workflow uses `GITHUB_TOKEN` which is automatically provided.

### Step 3: Enable GitHub Actions

1. Go to your repository on GitHub
2. Click **Actions** tab
3. Enable workflows if prompted
4. The CI/CD workflow will automatically run on push

### Step 4: Verify CI/CD Pipeline

```bash
# Make a change
echo "# Test" >> test.txt
git add test.txt
git commit -m "Test CI/CD"
git push

# Check GitHub Actions
# Go to: https://github.com/psyunix/golang/actions
```

The pipeline will:
1. ✅ Run tests
2. ✅ Build Docker image
3. ✅ Push to GitHub Container Registry
4. ✅ Update Kubernetes manifests

### Step 5: Pull and Deploy Docker Image

After successful CI/CD build:

```bash
# Login to GitHub Container Registry
echo $GITHUB_TOKEN | docker login ghcr.io -u psyunix --password-stdin

# Pull the image
docker pull ghcr.io/psyunix/golang-api:latest

# Update Kubernetes deployment
kubectl set image deployment/golang-api golang-api=ghcr.io/psyunix/golang-api:latest -n golang-app

# Verify rollout
kubectl rollout status deployment/golang-api -n golang-app
```

## Production Deployment Checklist

### Pre-Deployment

- [ ] All tests passing
- [ ] Code reviewed
- [ ] Documentation updated
- [ ] Environment variables configured
- [ ] Secrets properly set
- [ ] Resource limits appropriate
- [ ] Health checks working

### Deployment

- [ ] Create backup of current deployment
- [ ] Deploy to staging first
- [ ] Test all endpoints
- [ ] Monitor logs for errors
- [ ] Check resource usage
- [ ] Verify external access

### Post-Deployment

- [ ] Smoke tests passed
- [ ] Monitoring alerts configured
- [ ] Documentation updated
- [ ] Team notified
- [ ] Rollback plan ready

## Scaling

### Horizontal Scaling

```bash
# Scale to 5 replicas
kubectl scale deployment golang-api --replicas=5 -n golang-app

# Verify
kubectl get pods -n golang-app

# Auto-scaling (optional)
kubectl autoscale deployment golang-api --cpu-percent=80 --min=2 --max=10 -n golang-app
```

### Vertical Scaling

Edit `k8s/deployment.yaml`:

```yaml
resources:
  requests:
    memory: "256Mi"
    cpu: "200m"
  limits:
    memory: "512Mi"
    cpu: "400m"
```

Then apply:

```bash
kubectl apply -f k8s/deployment.yaml
```

## Monitoring and Maintenance

### View Metrics

```bash
# CPU and Memory usage
kubectl top pods -n golang-app

# Detailed pod info
kubectl describe pod <pod-name> -n golang-app
```

### Access Prometheus Metrics

```bash
# Port forward to access metrics
kubectl port-forward -n golang-app deployment/golang-api 9090:8080

# Access metrics
curl http://localhost:9090/metrics
```

### Log Aggregation

```bash
# Get logs from all pods
kubectl logs -l app=golang-api -n golang-app --tail=100

# Follow logs
kubectl logs -f -l app=golang-api -n golang-app
```

## Backup and Restore

### Backup Kubernetes Resources

```bash
# Backup all resources
kubectl get all -n golang-app -o yaml > backup-$(date +%Y%m%d).yaml

# Backup specific resources
kubectl get deployment golang-api -n golang-app -o yaml > deployment-backup.yaml
```

### Restore from Backup

```bash
kubectl apply -f backup-20241019.yaml
```

## Rollback

### Rollback Deployment

```bash
# View rollout history
kubectl rollout history deployment/golang-api -n golang-app

# Rollback to previous version
kubectl rollout undo deployment/golang-api -n golang-app

# Rollback to specific revision
kubectl rollout undo deployment/golang-api -n golang-app --to-revision=2
```

## Clean Up

### Remove Kubernetes Deployment

```bash
# Remove all resources
make k8s-delete

# Or manually
kubectl delete namespace golang-app
```

### Clean Docker Resources

```bash
# Stop containers
docker stop $(docker ps -q --filter ancestor=golang-api)

# Remove images
docker rmi golang-api:latest

# Clean system
docker system prune -a
```

## Troubleshooting

### Pods Not Starting

```bash
# Check pod status
kubectl get pods -n golang-app

# Describe pod
kubectl describe pod <pod-name> -n golang-app

# Check logs
kubectl logs <pod-name> -n golang-app

# Common issues:
# - Image pull errors: Check image name and registry access
# - CrashLoopBackOff: Check application logs
# - Pending: Check resource availability
```

### Service Not Accessible

```bash
# Check service
kubectl get svc -n golang-app

# Check endpoints
kubectl get endpoints -n golang-app

# Test from within cluster
kubectl run -it --rm debug --image=alpine --restart=Never -- sh
# Inside pod:
wget -qO- http://golang-api-service.golang-app:8080/health
```

### Image Pull Issues

```bash
# For private registry, create secret
kubectl create secret docker-registry ghcr-secret \
  --docker-server=ghcr.io \
  --docker-username=psyunix \
  --docker-password=$GITHUB_TOKEN \
  --docker-email=your-email@example.com \
  -n golang-app

# Add to deployment
# spec:
#   imagePullSecrets:
#   - name: ghcr-secret
```

## Performance Tuning

### Optimize Resource Limits

Monitor actual usage:

```bash
kubectl top pods -n golang-app
```

Adjust based on real usage patterns.

### Enable Caching

Add Redis or similar for caching frequently accessed data.

### Database Connection Pooling

Configure appropriate connection pool sizes based on load.

## Security Hardening

### Network Policies

Create network policies to restrict traffic:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: golang-api-netpol
  namespace: golang-app
spec:
  podSelector:
    matchLabels:
      app: golang-api
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector: {}
    ports:
    - protocol: TCP
      port: 8080
```

### Pod Security Standards

Apply pod security standards:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: golang-app
  labels:
    pod-security.kubernetes.io/enforce: restricted
    pod-security.kubernetes.io/audit: restricted
    pod-security.kubernetes.io/warn: restricted
```

## Support

For issues or questions:
- Check the README.md
- Review logs: `kubectl logs -n golang-app`
- GitHub Issues: https://github.com/psyunix/golang/issues
- UH ITS: https://www.hawaii.edu/its/

---

**Last Updated**: October 2025
**Maintained By**: psyunix @ UH ITS
