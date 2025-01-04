# Complete Docker Setup Guide for macOS

## 1. Install Docker Desktop

First, install Docker Desktop using Homebrew if you haven't already:
```bash
brew install --cask docker
```

Alternative methods:
- Download directly from Docker website: https://www.docker.com/products/docker-desktop
- Install via Mac App Store

## 2. Initial Setup

Start Docker Desktop:
```bash
# Open Docker Desktop from Applications folder
open -a Docker

# Wait for Docker to start (useful in scripts)
until docker info > /dev/null 2>&1; do
  echo "Waiting for Docker to start..."
  sleep 1
done
```

## 3. Configure Docker Settings

```bash
# Create docker config directory if it doesn't exist
mkdir -p ~/.docker

# Configure Docker daemon
cat > ~/.docker/daemon.json << EOL
{
  "features": {
    "buildkit": true
  },
  "experimental": false,
  "builder": {
    "gc": {
      "enabled": true,
      "defaultKeepStorage": "20GB"
    }
  },
  "registry-mirrors": [],
  "insecure-registries": []
}
EOL
```

## 4. Configure Resource Limits (via Docker Desktop)

Recommended settings for development:
- CPUs: 4-6 (depending on your machine)
- Memory: 8-16GB
- Swap: 1-2GB
- Disk image size: 60GB

These can be configured through Docker Desktop:
1. Open Docker Desktop
2. Click on Settings (⚙️)
3. Go to Resources section
4. Adjust the values as needed

## 5. Configure Shell Integration

Add Docker-related configurations to your shell profile:

```bash
# For Zsh (most common in modern macOS)
cat >> ~/.zshrc << EOL

# Docker aliases and functions
alias d='docker'
alias dc='docker-compose'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias dex='docker exec -it'
alias dlo='docker logs -f'

# Function to clean up Docker resources
docker-cleanup() {
  docker container prune -f
  docker image prune -f
  docker network prune -f
  docker volume prune -f
}

# Function to stop all running containers
docker-stop-all() {
  docker stop \$(docker ps -q)
}

# Function to remove all containers
docker-rm-all() {
  docker rm \$(docker ps -a -q)
}

# Function to remove all images
docker-rmi-all() {
  docker rmi \$(docker images -q)
}

# Docker compose environment defaults
export COMPOSE_DOCKER_CLI_BUILD=1
export DOCKER_BUILDKIT=1
EOL

# Source the updated profile
source ~/.zshrc
```

## 6. Configure Docker Compose

Install Docker Compose (if not already installed with Docker Desktop):
```bash
brew install docker-compose
```

Create default compose configuration:
```bash
mkdir -p ~/.docker/cli-plugins
ln -sfn /usr/local/opt/docker-compose/bin/docker-compose ~/.docker/cli-plugins/docker-compose
```

## 7. Configure Development Directory

```bash
# Create a dedicated directory for Docker projects
mkdir -p ~/Developer/Docker
```

## 8. Configure Global .dockerignore

```bash
# Create global dockerignore file
cat > ~/.dockerignore << EOL
# Version control
.git
.gitignore
.gitattributes
.svn
.hg

# Development
node_modules
*.log
.env
.env.*
*.env
!.env.example

# IDE
.idea
.vscode
*.swp
*.swo
*~

# OS generated files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# Build directories
dist
build
coverage
EOL
```

## 9. Configure Registry Authentication

```bash
# Log in to Docker Hub (if needed)
docker login

# For private registries
# docker login your-registry.example.com
```

## 10. Verify Installation

```bash
# Check Docker version
docker --version
docker-compose --version

# Verify Docker is running
docker info

# Run hello-world container
docker run hello-world
```

## 11. Optional: Configure Network Proxies

If you're behind a corporate proxy, configure Docker to use it:

1. Create/edit ~/.docker/config.json:
```json
{
  "proxies": {
    "default": {
      "httpProxy": "http://proxy.example.com:8080",
      "httpsProxy": "http://proxy.example.com:8080",
      "noProxy": "localhost,127.0.0.1,.example.com"
    }
  }
}
```

## 12. Common Issues and Solutions

### If Docker Desktop won't start:
```bash
# Reset Docker Desktop to factory defaults
rm -rf ~/Library/Group\ Containers/group.com.docker/
rm -rf ~/Library/Containers/com.docker.docker/
rm -rf ~/.docker/

# Reinstall Docker Desktop
brew uninstall --cask docker
brew install --cask docker
```

### If you get permission errors:
```bash
# Fix permissions for docker socket
sudo chmod 666 /var/run/docker.sock
```

### If Docker is using too much disk space:
```bash
# Clear build cache
docker builder prune

# Remove unused containers, networks, images
docker system prune -a --volumes
```

## FAQ

1. How to check Docker disk usage?
```bash
docker system df -v
```

2. How to get container IP address?
```bash
docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' container_name
```

3. How to copy files between host and container?
```bash
# Host to container
docker cp /path/to/file container_name:/path/in/container

# Container to host
docker cp container_name:/path/in/container /path/to/file
```

4. How to view container logs?
```bash
docker logs -f container_name
```

Remember to replace example values (like proxy URLs) with your actual values when needed.