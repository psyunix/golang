#!/bin/bash

# Quick Start Guide
# Run this script after creating the GitHub repository

set -e

echo "=================================================="
echo "GoLang API - Quick Start"
echo "=================================================="
echo ""

PROJECT_DIR="/Users/psyunix/Documents/git/claude/golang"
cd "$PROJECT_DIR"

echo "Step 1: Checking Prerequisites..."
echo "-----------------------------------"

# Check Go
if command -v go &> /dev/null; then
    GO_VERSION=$(go version)
    echo "✅ Go: $GO_VERSION"
else
    echo "❌ Go not found. Please install Go 1.21+"
    echo "   Download: https://golang.org/dl/"
    exit 1
fi

# Check Docker
if command -v docker &> /dev/null; then
    echo "✅ Docker: $(docker --version)"
    if ! docker ps &> /dev/null; then
        echo "⚠️  Docker daemon not running. Please start Docker Desktop."
    fi
else
    echo "❌ Docker not found. Please install Docker Desktop"
    echo "   Download: https://www.docker.com/products/docker-desktop"
    exit 1
fi

# Check kubectl
if command -v kubectl &> /dev/null; then
    echo "✅ kubectl: $(kubectl version --client --short 2>/dev/null || kubectl version --client)"
else
    echo "❌ kubectl not found. Please install kubectl"
    exit 1
fi

# Check make
if command -v make &> /dev/null; then
    echo "✅ make: $(make --version | head -n1)"
else
    echo "❌ make not found. Please install build tools"
    exit 1
fi

echo ""
echo "Step 2: Installing Go Dependencies..."
echo "--------------------------------------"
go mod download
go mod tidy
echo "✅ Dependencies installed"

echo ""
echo "Step 3: Building Application..."
echo "--------------------------------"
go build -o main ./cmd/api
echo "✅ Build successful"

echo ""
echo "Step 4: Running Tests..."
echo "-------------------------"
go test -v ./...
echo "✅ Tests passed"

echo ""
echo "Step 5: Building Docker Image..."
echo "----------------------------------"
docker build -t golang-api:latest .
echo "✅ Docker image built"

echo ""
echo "=================================================="
echo "✅ Setup Complete!"
echo "=================================================="
echo ""
echo "Quick Commands:"
echo "---------------"
echo "  make run              - Run API locally"
echo "  make test             - Run tests"
echo "  make docker-run       - Run in Docker"
echo "  make k8s-deploy       - Deploy to Kubernetes"
echo "  make k8s-status       - Check K8s status"
echo "  make help             - Show all commands"
echo ""
echo "Documentation:"
echo "--------------"
echo "  README.md        - Project overview"
echo "  DEPLOYMENT.md    - Deployment guide"
echo "  VSCODE.md        - VS Code integration"
echo ""
echo "Next Steps:"
echo "-----------"
echo "1. Run locally:       make run"
echo "2. Test:              curl http://localhost:8080/health"
echo "3. Deploy to K8s:     make k8s-deploy"
echo "4. Open in VS Code:   code ."
echo ""
echo "=================================================="
