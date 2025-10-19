package main

import (
	"fmt"
	"os"
	"runtime"
	"syscall"
	"time"

	log "github.com/sirupsen/logrus"
)

// SystemInfo holds system information
type SystemInfo struct {
	Hostname    string
	OS          string
	Arch        string
	CPUs        int
	GoVersion   string
	MemoryUsage uint64
	Uptime      time.Duration
}

func main() {
	log.SetFormatter(&log.TextFormatter{
		FullTimestamp: true,
	})

	// Get system information
	hostname, _ := os.Hostname()
	
	info := SystemInfo{
		Hostname:  hostname,
		OS:        runtime.GOOS,
		Arch:      runtime.GOARCH,
		CPUs:      runtime.NumCPU(),
		GoVersion: runtime.Version(),
	}

	// Get memory stats
	var m runtime.MemStats
	runtime.ReadMemStats(&m)
	info.MemoryUsage = m.Alloc / 1024 / 1024 // Convert to MB

	// Get system uptime (Linux/Unix only)
	var sysinfo syscall.Sysinfo_t
	if err := syscall.Sysinfo(&sysinfo); err == nil {
		info.Uptime = time.Duration(sysinfo.Uptime) * time.Second
	}

	// Display system information
	fmt.Println("\n" + repeatString("=", 60))
	fmt.Println("SYSTEM INFORMATION")
	fmt.Println(repeatString("=", 60))
	fmt.Printf("Timestamp:        %s\n", time.Now().Format(time.RFC1123))
	fmt.Printf("Hostname:         %s\n", info.Hostname)
	fmt.Printf("Operating System: %s\n", info.OS)
	fmt.Printf("Architecture:     %s\n", info.Arch)
	fmt.Printf("CPUs:             %d\n", info.CPUs)
	fmt.Printf("Go Version:       %s\n", info.GoVersion)
	fmt.Printf("Memory Usage:     %d MB\n", info.MemoryUsage)
	if info.Uptime > 0 {
		fmt.Printf("System Uptime:    %s\n", formatDuration(info.Uptime))
	}
	fmt.Println(repeatString("=", 60))

	// Log to structured logging
	log.WithFields(log.Fields{
		"hostname":     info.Hostname,
		"os":           info.OS,
		"arch":         info.Arch,
		"cpus":         info.CPUs,
		"go_version":   info.GoVersion,
		"memory_mb":    info.MemoryUsage,
		"uptime":       info.Uptime.String(),
	}).Info("System information collected")
}

func repeatString(s string, count int) string {
	result := ""
	for i := 0; i < count; i++ {
		result += s
	}
	return result
}

func formatDuration(d time.Duration) string {
	days := d / (24 * time.Hour)
	d -= days * 24 * time.Hour
	hours := d / time.Hour
	d -= hours * time.Hour
	minutes := d / time.Minute
	
	if days > 0 {
		return fmt.Sprintf("%dd %dh %dm", days, hours, minutes)
	}
	if hours > 0 {
		return fmt.Sprintf("%dh %dm", hours, minutes)
	}
	return fmt.Sprintf("%dm", minutes)
}
