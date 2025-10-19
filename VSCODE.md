# VS Code Integration Guide

This guide explains how to use VS Code with the GoLang API project for an enhanced development experience.

## Prerequisites

- **VS Code** installed
- **Go extension** for VS Code
- **Docker extension** for VS Code (optional)
- **Kubernetes extension** for VS Code (optional)

## Initial Setup

### 1. Open Project in VS Code

```bash
cd /Users/psyunix/Documents/git/claude/golang
code .
```

### 2. Install Recommended Extensions

When you open the project, VS Code will prompt you to install recommended extensions. Click **Install All**.

**Recommended Extensions:**
- **Go** (golang.go) - Essential for Go development
- **Kubernetes** (ms-kubernetes-tools.vscode-kubernetes-tools) - K8s management
- **Docker** (ms-azuretools.vscode-docker) - Docker support
- **YAML** (redhat.vscode-yaml) - YAML syntax support
- **GitLens** (eamodio.gitlens) - Enhanced Git features
- **GitHub Pull Requests** - GitHub integration

Alternatively, install manually:

```bash
code --install-extension golang.go
code --install-extension ms-kubernetes-tools.vscode-kubernetes-tools
code --install-extension ms-azuretools.vscode-docker
code --install-extension redhat.vscode-yaml
code --install-extension eamodio.gitlens
```

### 3. Configure Go Tools

Press `Cmd+Shift+P` and type: **Go: Install/Update Tools**

Select all tools and click **OK** to install:
- gopls (Go language server)
- dlv (Delve debugger)
- staticcheck (Linter)
- goimports (Import formatter)

## Development Features

### Code Completion and IntelliSense

- Type `Cmd+Space` for auto-completion
- Hover over functions/variables for documentation
- `Cmd+Click` to go to definition
- `Cmd+T` to search symbols

### Debugging

#### Debug Main API Server

1. Open `cmd/api/main.go`
2. Press `F5` or click **Run > Start Debugging**
3. Select **Launch API Server**

Set breakpoints by clicking left of line numbers.

**Debug Controls:**
- `F5` - Continue
- `F10` - Step Over
- `F11` - Step Into
- `Shift+F11` - Step Out
- `Shift+F5` - Stop

#### Debug Utility Scripts

1. Open the script (e.g., `scripts/check_services.go`)
2. Press `F5`
3. Select the appropriate configuration:
   - **Check Services Script**
   - **Port Check Script**
   - **System Info Script**

### Running Tasks

Press `Cmd+Shift+P` → **Tasks: Run Task**

Available tasks:
- **Build** - Compile the application
- **Run API Server** - Start the server
- **Run Tests** - Execute test suite
- **Docker Build** - Build Docker image
- **Docker Run** - Run container
- **Deploy to Kubernetes** - Deploy to K8s
- **Check Kubernetes Status** - View K8s resources
- **View Kubernetes Logs** - Stream logs
- **Check Services** - Run service checker
- **Port Check** - Run port scanner
- **System Info** - Display system info

### Quick Task Shortcuts

Add these to your `.vscode/keybindings.json`:

```json
[
  {
    "key": "cmd+shift+b",
    "command": "workbench.action.tasks.build"
  },
  {
    "key": "cmd+shift+t",
    "command": "workbench.action.tasks.test"
  }
]
```

### Code Formatting

- **Format Document**: `Shift+Alt+F`
- **Format Selection**: `Cmd+K Cmd+F`
- **Auto-format on save**: Already configured in settings

The project uses `goimports` which automatically:
- Formats code according to Go standards
- Adds missing imports
- Removes unused imports

### Code Navigation

- **Go to Definition**: `Cmd+Click` or `F12`
- **Go to Type Definition**: `Cmd+Click` (on type)
- **Find All References**: `Shift+F12`
- **Go to Symbol in File**: `Cmd+Shift+O`
- **Go to Symbol in Workspace**: `Cmd+T`

### Testing

#### Run Tests from Command Palette

1. Press `Cmd+Shift+P`
2. Type: **Go: Test Package**
3. Or: **Go: Test File**

#### Run Tests from Code Lens

Click **run test** or **debug test** above test functions:

```go
func TestHealthHandler(t *testing.T) { // <- Click "run test" here
    // test code
}
```

#### Coverage

- View coverage: **Go: Toggle Test Coverage In Current Package**
- Coverage appears as green (covered) and red (not covered) highlights

### Git Integration

#### Source Control Panel

- Press `Cmd+Shift+G` to open Source Control
- View changes, stage files, commit, push

#### GitLens Features (if installed)

- View blame information inline
- See commit history
- Compare branches
- File history

### Terminal Integration

Open integrated terminal: `Ctrl+` ` (backtick)

**Terminal Commands:**
```bash
# Build
make build

# Run
make run

# Test
make test

# Docker
make docker-build
make docker-run

# Kubernetes
make k8s-deploy
make k8s-status
```

### Docker Integration

If Docker extension is installed:

1. **View → Docker** to open Docker panel
2. View images, containers, registries
3. Right-click containers for quick actions
4. Build images directly from Dockerfile

### Kubernetes Integration

If Kubernetes extension is installed:

1. **View → Kubernetes** to open K8s panel
2. View clusters, nodes, pods, services
3. Right-click resources for actions:
   - View logs
   - Describe
   - Delete
   - Port forward

#### Deploy from VS Code

1. Right-click `k8s/deployment.yaml`
2. Select **Kubernetes: Apply**

#### View Logs

1. Kubernetes panel → Workloads → Pods
2. Right-click pod → **Logs**

## Integrated Terminal Workflows

### Development Workflow

```bash
# Terminal 1: Watch for changes and rebuild
make run

# Terminal 2: Run tests on save
make test

# Terminal 3: Monitor Kubernetes
make k8s-logs
```

### Split Terminal

- Split terminal: `Cmd+\`
- Navigate between: `Cmd+Option+Arrow`

## Snippets and Shortcuts

### Go Snippets

Type these prefixes and press `Tab`:

- `pkgm` - Package main declaration
- `func` - Function declaration
- `im` - Import statement
- `if` - If statement
- `for` - For loop
- `switch` - Switch statement

### Custom Snippets

Create custom snippets:
1. `Cmd+Shift+P` → **Preferences: Configure User Snippets**
2. Select **go.json**
3. Add your snippets

Example:

```json
{
  "HTTP Handler": {
    "prefix": "handler",
    "body": [
      "func ${1:handlerName}(w http.ResponseWriter, r *http.Request) {",
      "\tw.Header().Set(\"Content-Type\", \"application/json\")",
      "\t$0",
      "}"
    ],
    "description": "HTTP handler function"
  }
}
```

## Troubleshooting

### Go Extension Not Working

1. Check Go installation: `go version`
2. Restart VS Code
3. Run: **Go: Install/Update Tools**

### Debugger Not Attaching

1. Ensure `dlv` is installed
2. Check launch configuration in `.vscode/launch.json`
3. Kill existing processes on port 8080

### Import Errors

1. Run: `go mod tidy`
2. Run: `go mod download`
3. Reload VS Code: **Developer: Reload Window**

### Kubernetes Extension Issues

1. Verify `kubectl` is configured
2. Check cluster connection: `kubectl cluster-info`
3. Reload Kubernetes clusters in extension

## Productivity Tips

### Multi-Cursor Editing

- Add cursor: `Cmd+Option+Up/Down`
- Add cursor at all occurrences: `Cmd+Shift+L`

### Quick Open

- Open file: `Cmd+P`
- Open recent: `Cmd+R`
- Command palette: `Cmd+Shift+P`

### Panel Management

- Toggle sidebar: `Cmd+B`
- Toggle panel: `Cmd+J`
- Zen mode: `Cmd+K Z`

### Code Folding

- Fold: `Cmd+Option+[`
- Unfold: `Cmd+Option+]`
- Fold all: `Cmd+K Cmd+0`
- Unfold all: `Cmd+K Cmd+J`

### Search and Replace

- Find: `Cmd+F`
- Replace: `Cmd+Option+F`
- Find in files: `Cmd+Shift+F`
- Replace in files: `Cmd+Shift+H`

## Workspace Settings

The project includes workspace settings in `.vscode/settings.json`:

- Auto-format on save
- Go language server enabled
- Linting enabled
- Test coverage on save
- Import organization

You can customize these settings per your preferences.

## Remote Development

### SSH to Remote Server

1. Install **Remote - SSH** extension
2. Press `Cmd+Shift+P` → **Remote-SSH: Connect to Host**
3. Add host: `ssh username@hostname`
4. VS Code opens new window connected to remote
5. Open project folder on remote server

### Docker Containers

1. Install **Dev Containers** extension
2. Create `.devcontainer/devcontainer.json`
3. Open in container: **Dev Containers: Reopen in Container**

## GitHub Integration

### Clone Repository

```bash
# Via VS Code
Cmd+Shift+P → Git: Clone
Enter: https://github.com/psyunix/golang.git

# Via Terminal
git clone https://github.com/psyunix/golang.git
cd golang
code .
```

### Pull Requests

With GitHub Pull Requests extension:

1. View → GitHub Pull Requests
2. Create PR from VS Code
3. Review changes
4. Merge from editor

## Live Share (Optional)

Collaborate in real-time:

1. Install **Live Share** extension
2. Click **Live Share** in status bar
3. Share link with team
4. Collaborate on same code

## Keyboard Shortcuts Summary

| Action | Shortcut |
|--------|----------|
| Command Palette | `Cmd+Shift+P` |
| Quick Open | `Cmd+P` |
| Toggle Terminal | `Ctrl+` ` |
| Start Debugging | `F5` |
| Run Task | `Cmd+Shift+P` → Tasks |
| Format Document | `Shift+Alt+F` |
| Go to Definition | `F12` |
| Find References | `Shift+F12` |
| Toggle Sidebar | `Cmd+B` |
| Source Control | `Cmd+Shift+G` |
| Search Files | `Cmd+Shift+F` |

## Additional Resources

- [Go in VS Code](https://code.visualstudio.com/docs/languages/go)
- [VS Code Keyboard Shortcuts](https://code.visualstudio.com/shortcuts/keyboard-shortcuts-macos.pdf)
- [Debugging in VS Code](https://code.visualstudio.com/docs/editor/debugging)

## Support

For VS Code issues:
- [VS Code Documentation](https://code.visualstudio.com/docs)
- [Go Extension GitHub](https://github.com/golang/vscode-go)

---

**Happy Coding! 🚀**
