package main

import (
	"fmt"
	"net"
	"os"
	"strings"
	"time"

	log "github.com/sirupsen/logrus"
)

// PortCheck represents a port check result
type PortCheck struct {
	Host   string
	Port   string
	Status bool
}

func main() {
	log.SetFormatter(&log.TextFormatter{
		FullTimestamp: true,
	})

	// Services to check
	services := []struct {
		name string
		host string
		port string
	}{
		{"API Server", "localhost", "8080"},
		{"PostgreSQL", "localhost", "5432"},
		{"Redis", "localhost", "6379"},
		{"Kubernetes API", "localhost", "6443"},
	}

	fmt.Println("\n" + strings.Repeat("=", 70))
	fmt.Println("PORT CONNECTIVITY CHECK")
	fmt.Println(strings.Repeat("=", 70))
	fmt.Printf("Timestamp: %s\n\n", time.Now().Format(time.RFC1123))

	results := []PortCheck{}

	for _, svc := range services {
		address := fmt.Sprintf("%s:%s", svc.host, svc.port)
		
		log.Infof("Checking %s (%s)...", svc.name, address)
		
		conn, err := net.DialTimeout("tcp", address, 3*time.Second)
		status := err == nil
		
		if status {
			conn.Close()
			fmt.Printf("✓ %-20s | %s:%s | OPEN\n", svc.name, svc.host, svc.port)
			log.Infof("✓ %s is reachable", svc.name)
		} else {
			fmt.Printf("✗ %-20s | %s:%s | CLOSED\n", svc.name, svc.host, svc.port)
			log.Warnf("✗ %s is not reachable: %v", svc.name, err)
		}
		
		results = append(results, PortCheck{
			Host:   svc.host,
			Port:   svc.port,
			Status: status,
		})
		
		time.Sleep(500 * time.Millisecond)
	}

	fmt.Println(strings.Repeat("=", 70))
	
	// Summary
	openCount := 0
	for _, r := range results {
		if r.Status {
			openCount++
		}
	}
	
	fmt.Printf("\nSummary: %d/%d ports reachable\n", openCount, len(results))
	
	if openCount < len(results) {
		os.Exit(1)
	}
}
