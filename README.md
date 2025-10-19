# GoLang API with Docker & Kubernetes

A production-ready Go API service with Docker containerization, Kubernetes deployment, and CI/CD pipeline integration.

## 🚀 Features

- **RESTful API** - Built with Gorilla Mux router
- **Service Monitoring** - Health checks and status endpoints
- **Prometheus Metrics** - Built-in metrics endpoint
- **Docker Support** - Multi-stage Dockerfile for optimal image size
- **Kubernetes Ready** - Complete K8s manifests included
- **CI/CD Pipeline** - GitHub Actions workflow
- **VS Code Integration** - Debug configurations and tasks
- **Utility Scripts** - Service checking, port scanning, system info

## 📋 Prerequisites

- **Go 1.21+** - [Download](https://golang.org/dl/)
- **Docker Desktop** - [Download](https://www.docker.com/products/docker-desktop)
- **kubectl** - [Install](https://kubernetes.io/docs/tasks/tools/)
- **make** - Build automation tool
- **VS Code** - [Download](https://code.visualstudio.com/) (recommended)

## 🛠️ Quick Start

### 1. Clone the Repository

```bash
cd /Users/psyunix/Documents/git/claude/golang
```

### 2. Install Dependencies

```bash
make deps
```

### 3. Build the Application

```bash
make build
```

### 4. Run Locally

```bash
make run
```

The API will be available at `http://localhost:8080`

## 🐳 Docker

### Build Docker Image

```bash
make docker-build
```

### Run Docker Container

```bash
make docker-run
```

Access the API at `http://localhost:8080`

### Stop Docker Container

```bash
make docker-stop
```

## ☸️ Kubernetes Deployment

### Deploy to Local Kubernetes (Docker Desktop)

1. **Ensure Kubernetes is enabled in Docker Desktop**

2. **Deploy the application:**

```bash
make k8s-deploy
```

3. **Check deployment status:**

```bash
make k8s-status
```

4. **View logs:**

```bash
make k8s-logs
```

### Access the Application

After deployment, the service is available at:
- **NodePort**: `http://localhost:30080`
- **LoadBalancer**: Check with `kubectl get svc -n golang-app`

### Remove from Kubernetes

```bash
make k8s-delete
```

## 📡 API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/` | GET | Welcome message and API info |
| `/health` | GET | Health check endpoint |
| `/api/services` | GET | List all monitored services |
| `/api/services/{name}` | GET | Get specific service status |
| `/metrics` | GET | Prometheus metrics |

### Example Requests

```bash
# Health check
curl http://localhost:8080/health

# Get all services
curl http://localhost:8080/api/services

# Get specific service
curl http://localhost:8080/api/services/api-server

# Prometheus metrics
curl http://localhost:8080/metrics
```

## 🔧 Utility Scripts

### Check Services

Monitor service status via API:

```bash
make check-services
```

Or run directly:

```bash
go run scripts/check_services.go
```

### Port Connectivity Check

Check if services are reachable on their ports:

```bash
make port-check
```

### System Information

Display system and runtime information:

```bash
make system-info
```

## 🧪 Testing

### Run All Tests

```bash
make test
```

This generates a coverage report at `coverage.html`

### Run Tests with Race Detection

```bash
go test -v -race ./...
```

### Run Specific Tests

```bash
go test -v ./cmd/api -run TestHealthHandler
```

## 🔍 Code Quality

### Format Code

```bash
make fmt
```

### Run Linter

```bash
make vet
```

### Run Static Analysis

```bash
make lint
```

## 🚢 CI/CD Pipeline

The project includes a GitHub Actions workflow that:

1. **Tests** - Runs all tests with race detection
2. **Builds** - Creates Docker image
3. **Pushes** - Uploads to GitHub Container Registry
4. **Deploys** - Updates Kubernetes manifests

### GitHub Actions Workflow

Located at `.github/workflows/ci-cd.yaml`

**Triggers:**
- Push to `main` or `develop` branches
- Pull requests to `main`
- Manual workflow dispatch

**Image Registry:**
```
ghcr.io/psyunix/golang-api:latest
```

## 💻 VS Code Integration

### Recommended Extensions

The project includes recommended extensions in `.vscode/extensions.json`:
- Go (golang.go)
- Kubernetes Tools
- Docker
- YAML Support
- GitLens

### Debug Configurations

Press `F5` to launch:
- **Launch API Server** - Debug the main API
- **Check Services Script** - Debug service checker
- **Port Check Script** - Debug port scanner
- **System Info Script** - Debug system info tool

### Tasks

Access via `Cmd+Shift+P` → "Tasks: Run Task":
- Build
- Run API Server
- Run Tests
- Docker Build/Run
- Deploy to Kubernetes
- Check Kubernetes Status
- View Kubernetes Logs
- Check Services
- Port Check
- System Info

## 📁 Project Structure

```
golang/
├── cmd/
│   └── api/
│       └── main.go              # Main API server
├── scripts/
│   ├── check_services.go        # Service status checker
│   ├── port_check.go            # Port connectivity checker
│   └── system_info.go           # System information tool
├── k8s/
│   ├── namespace.yaml           # Kubernetes namespace
│   ├── deployment.yaml          # Deployment and services
│   └── configmap.yaml           # Configuration and secrets
├── .github/
│   └── workflows/
│       └── ci-cd.yaml           # CI/CD pipeline
├── .vscode/
│   ├── settings.json            # VS Code settings
│   ├── launch.json              # Debug configurations
│   ├── tasks.json               # Build tasks
│   └── extensions.json          # Recommended extensions
├── Dockerfile                   # Multi-stage Docker build
├── Makefile                     # Build automation
├── go.mod                       # Go module definition
├── go.sum                       # Dependency checksums
└── README.md                    # This file
```

## 🔐 Security

### Container Security

- Non-root user in container
- Minimal Alpine base image
- Multi-stage build for smaller attack surface
- Health checks included

### Kubernetes Security

- Resource limits configured
- Liveness and readiness probes
- Secrets management via ConfigMap/Secrets
- Namespace isolation

## 📊 Monitoring

### Prometheus Metrics

The API exposes metrics at `/metrics` for Prometheus scraping:

```bash
curl http://localhost:8080/metrics
```

### Health Checks

Kubernetes uses built-in health endpoints:
- **Liveness**: `/health` - Restarts pod if unhealthy
- **Readiness**: `/health` - Removes from service if not ready

## 🔧 Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `PORT` | `8080` | Server port |
| `LOG_LEVEL` | `info` | Logging level (debug, info, warn, error) |
| `API_URL` | `http://localhost:8080` | API URL for scripts |

### Kubernetes ConfigMap

Edit `k8s/configmap.yaml` to modify configuration:

```yaml
data:
  API_URL: "http://golang-api-service:8080"
  LOG_LEVEL: "info"
  ENVIRONMENT: "development"
```

## 🚀 Deployment Guide

### Step-by-Step Deployment

#### 1. Local Development

```bash
# Install dependencies
make deps

# Run tests
make test

# Run locally
make run
```

Test at `http://localhost:8080`

#### 2. Docker Build

```bash
# Build image
make docker-build

# Run container
make docker-run
```

#### 3. Kubernetes Deployment

```bash
# Deploy to K8s
make k8s-deploy

# Verify deployment
kubectl get pods -n golang-app
kubectl get svc -n golang-app

# Test the service
curl http://localhost:30080/health
```

#### 4. CI/CD Setup

1. Push code to GitHub
2. GitHub Actions automatically:
   - Runs tests
   - Builds Docker image
   - Pushes to GHCR
   - Updates K8s manifests

## 📝 Development Workflow

### Making Changes

1. **Create a feature branch:**
```bash
git checkout -b feature/my-feature
```

2. **Make changes and test:**
```bash
make test
make run
```

3. **Commit and push:**
```bash
git add .
git commit -m "Add my feature"
git push origin feature/my-feature
```

4. **Create Pull Request** on GitHub

5. **CI/CD will automatically:**
   - Run tests
   - Build Docker image
   - Report status

### Adding New Endpoints

1. Edit `cmd/api/main.go`
2. Add your handler function
3. Register route in `main()`
4. Add tests
5. Update documentation

Example:

```go
func myNewHandler(w http.ResponseWriter, r *http.Request) {
    response := map[string]string{
        "message": "My new endpoint",
    }
    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode(response)
}

// In main():
router.HandleFunc("/api/mynew", myNewHandler).Methods("GET")
```

## 🐛 Troubleshooting

### Common Issues

#### Port Already in Use

```bash
# Find process using port 8080
lsof -i :8080

# Kill the process
kill -9 <PID>
```

#### Kubernetes Pod Not Starting

```bash
# Check pod status
kubectl describe pod <pod-name> -n golang-app

# Check logs
kubectl logs <pod-name> -n golang-app

# Check events
kubectl get events -n golang-app
```

#### Docker Build Fails

```bash
# Clean Docker cache
docker system prune -a

# Rebuild
make docker-build
```

#### Go Module Issues

```bash
# Clean module cache
go clean -modcache

# Re-download dependencies
make deps
```

## 📚 Additional Resources

### Go Development
- [Go Documentation](https://golang.org/doc/)
- [Effective Go](https://golang.org/doc/effective_go)
- [Go by Example](https://gobyexample.com/)

### Docker
- [Docker Documentation](https://docs.docker.com/)
- [Dockerfile Best Practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)

### Kubernetes
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)

### CI/CD
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 📄 License

MIT License - feel free to use this project for your own purposes.

## 👤 Author

**psyunix**
- GitHub: [@psyunix](https://github.com/psyunix)
- University of Hawaii ITS

## 🙏 Acknowledgments

- Built with Go and modern DevOps practices
- Designed for Docker Desktop Kubernetes
- Integrated with VS Code for enhanced development experience

---

**Need Help?** Open an issue on GitHub or contact the ITS team at University of Hawaii at Manoa.
