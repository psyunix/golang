# Multi-stage build for Go development environment
FROM golang:1.21-alpine AS builder

# Install build dependencies
RUN apk add --no-cache git make bash curl

# Create app directory
WORKDIR /app

# Copy go mod files
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy source code
COPY . .

# Build the application
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main ./cmd/api

# Final stage - minimal runtime image
FROM alpine:latest

# Install runtime dependencies
RUN apk --no-cache add ca-certificates curl bash

# Create non-root user
RUN addgroup -g 1000 goapp && \
    adduser -D -u 1000 -G goapp goapp

WORKDIR /home/goapp

# Copy binary from builder
COPY --from=builder /app/main .
COPY --from=builder /app/scripts ./scripts

# Set ownership
RUN chown -R goapp:goapp /home/goapp

# Switch to non-root user
USER goapp

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

# Run the application
CMD ["./main"]
