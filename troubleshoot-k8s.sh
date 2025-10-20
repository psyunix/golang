#!/bin/bash

# Kubernetes Troubleshooting Script
# Run this to diagnose deployment issues

echo "=================================================="
echo "Kubernetes Deployment Troubleshooting"
echo "=================================================="
echo ""

# Check pods
echo "1. Checking Pods Status:"
echo "-----------------------------------"
kubectl get pods -n golang-app
echo ""

# Describe pods to see events
echo "2. Pod Events and Details:"
echo "-----------------------------------"
for pod in $(kubectl get pods -n golang-app -o jsonpath='{.items[*].metadata.name}'); do
    echo ""
    echo "Pod: $pod"
    echo "---"
    kubectl describe pod $pod -n golang-app | grep -A 20 "Events:"
done
echo ""

# Check deployment status
echo "3. Deployment Status:"
echo "-----------------------------------"
kubectl describe deployment golang-api -n golang-app | grep -A 10 "Conditions:"
echo ""

# Check if image can be pulled
echo "4. Checking Image:"
echo "-----------------------------------"
kubectl get deployment golang-api -n golang-app -o jsonpath='{.spec.template.spec.containers[0].image}'
echo ""
echo ""

# Check logs if pods exist
echo "5. Pod Logs (if available):"
echo "-----------------------------------"
kubectl logs -l app=golang-api -n golang-app --tail=50
echo ""

# Check services
echo "6. Services:"
echo "-----------------------------------"
kubectl get svc -n golang-app
echo ""

# Summary
echo "=================================================="
echo "Common Issues:"
echo "=================================================="
echo "1. ImagePullBackOff - Image not accessible"
echo "   Solution: Make package public at https://github.com/psyunix?tab=packages"
echo ""
echo "2. CrashLoopBackOff - Application crashing"
echo "   Solution: Check logs above for errors"
echo ""
echo "3. Pending - Not enough resources"
echo "   Solution: Check Docker Desktop resources"
echo ""
echo "=================================================="
