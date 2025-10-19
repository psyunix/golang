.PHONY: help build run test clean docker-build docker-run k8s-deploy k8s-delete

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-20s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

build: ## Build the Go application
	@echo "Building application..."
	go build -o main ./cmd/api

run: ## Run the application locally
	@echo "Running application..."
	go run ./cmd/api/main.go

test: ## Run tests
	@echo "Running tests..."
	go test -v -race -coverprofile=coverage.out ./...
	go tool cover -html=coverage.out -o coverage.html

clean: ## Clean build artifacts
	@echo "Cleaning..."
	rm -f main coverage.out coverage.html
	go clean

deps: ## Download dependencies
	@echo "Downloading dependencies..."
	go mod download
	go mod tidy

vet: ## Run go vet
	@echo "Running go vet..."
	go vet ./...

fmt: ## Format code
	@echo "Formatting code..."
	go fmt ./...

lint: ## Run linter
	@echo "Running linter..."
	golangci-lint run

docker-build: ## Build Docker image
	@echo "Building Docker image..."
	docker build -t golang-api:latest .

docker-run: ## Run Docker container locally
	@echo "Running Docker container..."
	docker run -p 8080:8080 --name golang-api golang-api:latest

docker-stop: ## Stop Docker container
	@echo "Stopping Docker container..."
	docker stop golang-api
	docker rm golang-api

k8s-deploy: ## Deploy to Kubernetes
	@echo "Deploying to Kubernetes..."
	kubectl apply -f k8s/namespace.yaml
	kubectl apply -f k8s/configmap.yaml
	kubectl apply -f k8s/deployment.yaml
	@echo "Waiting for deployment to be ready..."
	kubectl wait --for=condition=available --timeout=300s deployment/golang-api -n golang-app

k8s-delete: ## Delete from Kubernetes
	@echo "Deleting from Kubernetes..."
	kubectl delete -f k8s/deployment.yaml
	kubectl delete -f k8s/configmap.yaml
	kubectl delete -f k8s/namespace.yaml

k8s-logs: ## View Kubernetes logs
	kubectl logs -f -l app=golang-api -n golang-app

k8s-status: ## Check Kubernetes deployment status
	kubectl get all -n golang-app

check-services: ## Run service check script
	@echo "Checking services..."
	go run scripts/check_services.go

port-check: ## Run port check script
	@echo "Checking ports..."
	go run scripts/port_check.go

system-info: ## Display system information
	@echo "Getting system information..."
	go run scripts/system_info.go

all: clean deps fmt vet test build ## Run all checks and build
