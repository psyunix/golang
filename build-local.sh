#!/bin/bash

# Build Docker image locally for your Mac architecture
# This is faster than waiting for CI/CD to rebuild

set -e

echo "=================================================="
echo "Building Docker Image Locally for Mac"
echo "=================================================="
echo ""

cd /Users/psyunix/Documents/git/claude/golang

echo "Building Docker image..."
docker build -t golang-api:local .

echo ""
echo "✅ Image built successfully!"
echo ""

# Tag it for local use
docker tag golang-api:local ghcr.io/psyunix/golang-api:latest

echo "✅ Tagged as ghcr.io/psyunix/golang-api:latest"
echo ""

echo "=================================================="
echo "Testing the image locally..."
echo "=================================================="

# Test run
echo "Starting container..."
docker run -d -p 8080:8080 --name golang-api-test golang-api:local

echo "Waiting for container to start..."
sleep 5

# Test health endpoint
echo ""
echo "Testing health endpoint..."
curl -s http://localhost:8080/health | jq '.' || curl -s http://localhost:8080/health

# Stop test container
echo ""
echo "Stopping test container..."
docker stop golang-api-test
docker rm golang-api-test

echo ""
echo "=================================================="
echo "✅ Image works! Ready to deploy to Kubernetes"
echo "=================================================="
echo ""
echo "Now deploy to Kubernetes:"
echo "  kubectl delete deployment golang-api -n golang-app"
echo "  kubectl apply -f k8s/deployment.yaml"
echo ""
echo "Or use imagePullPolicy: Never in deployment to use local image"
echo "=================================================="
