package main

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"time"

	log "github.com/sirupsen/logrus"
)

// ServiceStatus represents a service status
type ServiceStatus struct {
	Name      string    `json:"name"`
	Status    string    `json:"status"`
	Uptime    string    `json:"uptime"`
	Timestamp time.Time `json:"timestamp"`
}

func main() {
	log.SetFormatter(&log.TextFormatter{
		FullTimestamp: true,
	})
	log.SetOutput(os.Stdout)

	// Get API URL from environment or use default
	apiURL := os.Getenv("API_URL")
	if apiURL == "" {
		apiURL = "http://localhost:8080"
	}

	log.Infof("Checking services at %s", apiURL)

	// Check health endpoint
	healthURL := fmt.Sprintf("%s/health", apiURL)
	resp, err := http.Get(healthURL)
	if err != nil {
		log.Errorf("Failed to connect to API: %v", err)
		os.Exit(1)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		log.Errorf("Health check failed with status: %d", resp.StatusCode)
		os.Exit(1)
	}

	log.Info("✓ API is healthy")

	// Get all services
	servicesURL := fmt.Sprintf("%s/api/services", apiURL)
	resp, err = http.Get(servicesURL)
	if err != nil {
		log.Errorf("Failed to get services: %v", err)
		os.Exit(1)
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		log.Errorf("Failed to read response: %v", err)
		os.Exit(1)
	}

	var services []ServiceStatus
	if err := json.Unmarshal(body, &services); err != nil {
		log.Errorf("Failed to parse services: %v", err)
		os.Exit(1)
	}

	// Print service status
	fmt.Println("\n" + "=".repeat(60))
	fmt.Println("SERVICE STATUS REPORT")
	fmt.Println("=".repeat(60))
	fmt.Printf("Timestamp: %s\n\n", time.Now().Format(time.RFC1123))

	for _, service := range services {
		statusIcon := "✓"
		if service.Status != "running" {
			statusIcon = "✗"
		}

		fmt.Printf("%s %-20s | Status: %-10s | Uptime: %s\n",
			statusIcon,
			service.Name,
			service.Status,
			service.Uptime,
		)
	}

	fmt.Println("=".repeat(60))
	fmt.Printf("\nTotal Services: %d\n", len(services))
	
	// Count running services
	runningCount := 0
	for _, service := range services {
		if service.Status == "running" {
			runningCount++
		}
	}
	
	fmt.Printf("Running: %d | Not Running: %d\n", runningCount, len(services)-runningCount)
}

// Helper function to repeat strings
func repeat(s string, count int) string {
	result := ""
	for i := 0; i < count; i++ {
		result += s
	}
	return result
}

func init() {
	// Make string repeat available
	type stringHelper string
	
	var sh stringHelper
	_ = sh
}
