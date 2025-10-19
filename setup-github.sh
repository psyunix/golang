#!/bin/bash

# Setup script for GoLang API project
# This script initializes Git, creates GitHub repository, and sets up CI/CD

set -e

PROJECT_DIR="/Users/psyunix/Documents/git/claude/golang"
GITHUB_USER="psyunix"
REPO_NAME="golang"

echo "=================================================="
echo "GoLang API - GitHub Setup Script"
echo "=================================================="
echo ""

cd "$PROJECT_DIR"

# Check if Git is initialized
if [ ! -d ".git" ]; then
    echo "📦 Initializing Git repository..."
    git init
    echo "✅ Git initialized"
else
    echo "✅ Git already initialized"
fi

# Add all files
echo ""
echo "📝 Adding files to Git..."
git add .

# Create initial commit if needed
if ! git rev-parse HEAD >/dev/null 2>&1; then
    echo "💾 Creating initial commit..."
    git commit -m "Initial commit: Go API with Docker and Kubernetes

Features:
- RESTful API with Gorilla Mux
- Service monitoring endpoints
- Prometheus metrics integration
- Docker multi-stage build
- Kubernetes manifests (namespace, deployment, service)
- GitHub Actions CI/CD pipeline
- VS Code integration (debug, tasks)
- Utility scripts (service check, port scan, system info)
- Comprehensive documentation"
    echo "✅ Initial commit created"
else
    echo "✅ Commits already exist"
fi

# Set main branch
echo ""
echo "🌿 Setting main branch..."
git branch -M main

# Check if remote exists
if git remote get-url origin >/dev/null 2>&1; then
    echo "✅ Remote 'origin' already configured"
    REMOTE_URL=$(git remote get-url origin)
    echo "   URL: $REMOTE_URL"
else
    echo "🔗 Adding remote origin..."
    git remote add origin "https://github.com/$GITHUB_USER/$REPO_NAME.git"
    echo "✅ Remote added: https://github.com/$GITHUB_USER/$REPO_NAME.git"
fi

echo ""
echo "=================================================="
echo "Next Steps:"
echo "=================================================="
echo ""
echo "1. Create GitHub repository:"
echo "   Go to: https://github.com/new"
echo "   Repository name: $REPO_NAME"
echo "   Description: Go API with Docker and Kubernetes"
echo "   Public or Private: Your choice"
echo "   ⚠️  DO NOT initialize with README, .gitignore, or license"
echo ""
echo "2. Push to GitHub:"
echo "   cd $PROJECT_DIR"
echo "   git push -u origin main"
echo ""
echo "3. Verify CI/CD:"
echo "   https://github.com/$GITHUB_USER/$REPO_NAME/actions"
echo ""
echo "4. Pull Docker image after CI/CD completes:"
echo "   docker pull ghcr.io/$GITHUB_USER/golang-api:latest"
echo ""
echo "5. Deploy to Kubernetes:"
echo "   make k8s-deploy"
echo ""
echo "=================================================="
echo "Files created and ready to push!"
echo "=================================================="
echo ""

# Show git status
git status

echo ""
echo "✅ Setup complete! Follow the next steps above."
