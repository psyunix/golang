# GitHub Setup Instructions

## Step 1: Create GitHub Repository

### Option A: Using GitHub Web Interface (Recommended)

1. **Go to GitHub**: https://github.com/new

2. **Fill in repository details**:
   - **Repository name**: `golang`
   - **Description**: `Go API with Docker and Kubernetes deployment`
   - **Visibility**: Choose Public or Private
   - **⚠️ IMPORTANT**: Do NOT initialize with:
     - ❌ README
     - ❌ .gitignore
     - ❌ license
   
3. **Click**: "Create repository"

### Option B: Using GitHub CLI (if installed)

```bash
cd /Users/psyunix/Documents/git/claude/golang
gh repo create golang --public --description "Go API with Docker and Kubernetes deployment" --source=. --push
```

## Step 2: Push Code to GitHub

After creating the repository on GitHub, push the code:

```bash
cd /Users/psyunix/Documents/git/claude/golang

# Push to GitHub
git push -u origin main
```

**Expected output:**
```
Enumerating objects: 18, done.
Counting objects: 100% (18/18), done.
Delta compression using up to 8 threads
Compressing objects: 100% (16/16), done.
Writing objects: 100% (18/18), 25.41 KiB | 2.54 MiB/s, done.
Total 18 (delta 0), reused 0 (delta 0), pack-reused 0
To https://github.com/psyunix/golang.git
 * [new branch]      main -> main
Branch 'main' set up to track remote branch 'main' from 'origin'.
```

## Step 3: Verify Repository

1. Go to: https://github.com/psyunix/golang
2. You should see all your files
3. README.md will be displayed on the main page

## Step 4: Enable GitHub Actions

GitHub Actions should be automatically enabled. Verify:

1. Go to: https://github.com/psyunix/golang/actions
2. You should see the workflow run triggered by your push
3. Click on the workflow run to see details

The CI/CD pipeline will:
- ✅ Run tests
- ✅ Build Docker image
- ✅ Push to GitHub Container Registry (ghcr.io)

## Step 5: Configure Package Permissions (for Docker images)

1. Go to: https://github.com/psyunix?tab=packages
2. Find `golang-api` package
3. Click on it
4. Go to **Package settings**
5. Under **Manage Actions access**, ensure the repository has write access

## Step 6: Pull Docker Image

After the CI/CD completes successfully:

```bash
# Login to GitHub Container Registry (if needed)
echo $GITHUB_TOKEN | docker login ghcr.io -u psyunix --password-stdin

# Or use personal access token
docker login ghcr.io -u psyunix

# Pull the image
docker pull ghcr.io/psyunix/golang-api:latest

# Run it
docker run -p 8080:8080 ghcr.io/psyunix/golang-api:latest
```

## Step 7: Update Kubernetes Deployment

Update the deployment to use the GitHub Container Registry image:

```bash
cd /Users/psyunix/Documents/git/claude/golang

# Edit k8s/deployment.yaml
# Change: image: ghcr.io/psyunix/golang-api:latest

# Deploy
kubectl apply -f k8s/
```

## Troubleshooting

### "Repository not found" error

**Problem**: When pushing, you get "remote: Repository not found"

**Solution**: 
1. Make sure you created the repository on GitHub first
2. Check the remote URL:
   ```bash
   git remote -v
   ```
3. Should show: `https://github.com/psyunix/golang.git`

### Authentication issues

**Problem**: Git asks for username/password repeatedly

**Solution**: Use Personal Access Token (PAT)

1. Go to: https://github.com/settings/tokens
2. Click: **Generate new token** → **Generate new token (classic)**
3. Give it a name: "GoLang Project"
4. Select scopes:
   - `repo` (full repository access)
   - `write:packages` (for Docker images)
5. Generate and copy the token
6. Use token as password when pushing

**Better Solution**: Use SSH keys

```bash
# Generate SSH key (if you don't have one)
ssh-keygen -t ed25519 -C "your_email@example.com"

# Add to ssh-agent
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# Copy public key
cat ~/.ssh/id_ed25519.pub

# Add to GitHub: https://github.com/settings/keys
# Click "New SSH key", paste the key

# Change remote to SSH
cd /Users/psyunix/Documents/git/claude/golang
git remote set-url origin git@github.com:psyunix/golang.git

# Push
git push -u origin main
```

### GitHub Actions not running

**Problem**: No workflows appearing in Actions tab

**Solution**:
1. Check if Actions are enabled: Repository Settings → Actions → General
2. Ensure workflow file is in `.github/workflows/` directory
3. Check workflow syntax is valid YAML

### Docker image not building in CI/CD

**Problem**: CI/CD fails at Docker build step

**Solution**:
1. Check the Actions log for specific error
2. Common issues:
   - Dockerfile syntax error
   - go.mod/go.sum out of sync (run `go mod tidy`)
   - Missing dependencies

### Can't pull Docker image

**Problem**: Permission denied when pulling from ghcr.io

**Solution**:
1. Make package public: Package settings → Change visibility → Public
2. Or authenticate:
   ```bash
   echo $GITHUB_TOKEN | docker login ghcr.io -u psyunix --password-stdin
   ```

## Continuous Integration Workflow

Every time you push code:

1. **Push to GitHub**:
   ```bash
   git add .
   git commit -m "Your commit message"
   git push
   ```

2. **GitHub Actions automatically**:
   - Runs tests
   - Builds Docker image
   - Pushes to ghcr.io
   - Tags with branch name and SHA

3. **Deploy to Kubernetes**:
   ```bash
   # Pull latest image
   docker pull ghcr.io/psyunix/golang-api:latest
   
   # Update K8s deployment
   kubectl set image deployment/golang-api \
     golang-api=ghcr.io/psyunix/golang-api:latest \
     -n golang-app
   
   # Verify rollout
   kubectl rollout status deployment/golang-api -n golang-app
   ```

## Branch Strategy

### Development Workflow

```bash
# Create feature branch
git checkout -b feature/my-feature

# Make changes
# ... code ...

# Commit
git add .
git commit -m "Add my feature"

# Push feature branch
git push -u origin feature/my-feature

# Create Pull Request on GitHub
# After review and merge, delete branch
git checkout main
git pull
git branch -d feature/my-feature
```

### Release Workflow

```bash
# Tag a release
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0

# This will trigger CI/CD with the version tag
```

## Useful Git Commands

```bash
# View commit history
git log --oneline --graph

# View remote info
git remote -v

# Check current branch
git branch

# Sync with remote
git fetch
git pull

# Undo last commit (keep changes)
git reset --soft HEAD~1

# View changes
git status
git diff

# Stash changes
git stash
git stash pop
```

## Next Steps

1. ✅ Repository created and pushed
2. ✅ CI/CD pipeline running
3. ✅ Docker image available
4. 🔄 Deploy to Kubernetes
5. 📝 Start development!

---

**Need Help?**
- GitHub Docs: https://docs.github.com
- Git Docs: https://git-scm.com/doc
- Project README: README.md
