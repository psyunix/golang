#!/bin/bash

# Deploy to Kubernetes with proper sequencing
# This script ensures namespace is ready before deploying resources

set -e

PROJECT_DIR="/Users/psyunix/Documents/git/claude/golang"
cd "$PROJECT_DIR"

echo "=================================================="
echo "Deploying GoLang API to Kubernetes"
echo "=================================================="
echo ""

# Step 1: Create namespace
echo "Step 1: Creating namespace..."
kubectl apply -f k8s/namespace.yaml

# Wait for namespace to be ready
echo "Waiting for namespace to be ready..."
sleep 3

# Verify namespace exists
if kubectl get namespace golang-app &> /dev/null; then
    echo "✅ Namespace golang-app is ready"
else
    echo "❌ Namespace golang-app not found"
    exit 1
fi

# Step 2: Create ConfigMap and Secrets
echo ""
echo "Step 2: Creating ConfigMap and Secrets..."
kubectl apply -f k8s/configmap.yaml

# Wait a moment
sleep 2

# Step 3: Create Deployment and Services
echo ""
echo "Step 3: Creating Deployment and Services..."
kubectl apply -f k8s/deployment.yaml

# Step 4: Wait for deployment to be ready
echo ""
echo "Step 4: Waiting for deployment to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/golang-api -n golang-app

# Step 5: Show status
echo ""
echo "=================================================="
echo "Deployment Complete!"
echo "=================================================="
echo ""
echo "Resources created:"
kubectl get all -n golang-app

echo ""
echo "=================================================="
echo "Access your application:"
echo "=================================================="
echo "NodePort:       http://localhost:30080"
echo "Health Check:   curl http://localhost:30080/health"
echo "Services List:  curl http://localhost:30080/api/services"
echo ""
echo "To view logs:   kubectl logs -f -l app=golang-api -n golang-app"
echo "To delete:      kubectl delete -f k8s/"
echo "=================================================="
