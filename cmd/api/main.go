package main

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/gorilla/mux"
	"github.com/prometheus/client_golang/prometheus/promhttp"
	log "github.com/sirupsen/logrus"
)

// ServiceStatus represents the status of a service
type ServiceStatus struct {
	Name      string    `json:"name"`
	Status    string    `json:"status"`
	Uptime    string    `json:"uptime"`
	Timestamp time.Time `json:"timestamp"`
}

// HealthResponse represents the health check response
type HealthResponse struct {
	Status    string    `json:"status"`
	Timestamp time.Time `json:"timestamp"`
	Version   string    `json:"version"`
}

var startTime time.Time

func init() {
	// Set up logging
	log.SetFormatter(&log.JSONFormatter{})
	log.SetOutput(os.Stdout)
	log.SetLevel(log.InfoLevel)
	
	startTime = time.Now()
}

func main() {
	log.Info("Starting Go API Server...")

	router := mux.NewRouter()

	// API routes
	router.HandleFunc("/", homeHandler).Methods("GET")
	router.HandleFunc("/health", healthHandler).Methods("GET")
	router.HandleFunc("/api/services", getServicesHandler).Methods("GET")
	router.HandleFunc("/api/services/{name}", getServiceHandler).Methods("GET")
	
	// Metrics endpoint for Prometheus
	router.Handle("/metrics", promhttp.Handler())

	// Server configuration
	srv := &http.Server{
		Addr:         ":8080",
		Handler:      router,
		ReadTimeout:  15 * time.Second,
		WriteTimeout: 15 * time.Second,
		IdleTimeout:  60 * time.Second,
	}

	// Start server in a goroutine
	go func() {
		log.Infof("Server listening on %s", srv.Addr)
		if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("Server failed to start: %v", err)
		}
	}()

	// Graceful shutdown
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit

	log.Info("Shutting down server...")
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	if err := srv.Shutdown(ctx); err != nil {
		log.Fatalf("Server forced to shutdown: %v", err)
	}

	log.Info("Server exited")
}

func homeHandler(w http.ResponseWriter, r *http.Request) {
	response := map[string]string{
		"message": "Welcome to Go Service Monitor API",
		"version": "1.0.0",
		"uptime":  time.Since(startTime).String(),
	}
	
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
	
	log.WithFields(log.Fields{
		"path":   r.URL.Path,
		"method": r.Method,
		"remote": r.RemoteAddr,
	}).Info("Home endpoint accessed")
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
	health := HealthResponse{
		Status:    "healthy",
		Timestamp: time.Now(),
		Version:   "1.0.0",
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(health)
	
	log.Debug("Health check performed")
}

func getServicesHandler(w http.ResponseWriter, r *http.Request) {
	services := []ServiceStatus{
		{
			Name:      "api-server",
			Status:    "running",
			Uptime:    time.Since(startTime).String(),
			Timestamp: time.Now(),
		},
		{
			Name:      "database",
			Status:    "running",
			Uptime:    "48h30m",
			Timestamp: time.Now(),
		},
		{
			Name:      "cache",
			Status:    "running",
			Uptime:    "24h15m",
			Timestamp: time.Now(),
		},
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(services)
	
	log.WithFields(log.Fields{
		"path":        r.URL.Path,
		"method":      r.Method,
		"service_count": len(services),
	}).Info("Services list requested")
}

func getServiceHandler(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	serviceName := vars["name"]

	// Mock service data
	services := map[string]ServiceStatus{
		"api-server": {
			Name:      "api-server",
			Status:    "running",
			Uptime:    time.Since(startTime).String(),
			Timestamp: time.Now(),
		},
		"database": {
			Name:      "database",
			Status:    "running",
			Uptime:    "48h30m",
			Timestamp: time.Now(),
		},
		"cache": {
			Name:      "cache",
			Status:    "running",
			Uptime:    "24h15m",
			Timestamp: time.Now(),
		},
	}

	service, exists := services[serviceName]
	if !exists {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusNotFound)
		json.NewEncoder(w).Encode(map[string]string{
			"error": fmt.Sprintf("Service '%s' not found", serviceName),
		})
		log.WithField("service", serviceName).Warn("Service not found")
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(service)
	
	log.WithFields(log.Fields{
		"service": serviceName,
		"status":  service.Status,
	}).Info("Service status requested")
}
