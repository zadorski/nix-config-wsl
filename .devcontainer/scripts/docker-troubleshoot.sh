#!/usr/bin/env bash
# Docker build troubleshooting script

set -e

echo "🔍 Docker Troubleshooting Tool"
echo "============================="

# check docker daemon
echo "Checking Docker daemon status..."
if ! docker info &>/dev/null; then
  echo "❌ Docker daemon is not running or not accessible"
  echo "Try restarting Docker with: 'sudo systemctl restart docker'"
  exit 1
fi

# check network connectivity
echo "Checking network connectivity..."
if ! curl -s --connect-timeout 5 https://registry-1.docker.io/v2/ &>/dev/null; then
  echo "❌ Cannot connect to Docker Hub registry"
  echo "Check your network connection and proxy settings"
  
  # check proxy settings
  if [ -n "$HTTP_PROXY" ] || [ -n "$HTTPS_PROXY" ]; then
    echo "Proxy settings detected:"
    echo "HTTP_PROXY=$HTTP_PROXY"
    echo "HTTPS_PROXY=$HTTPS_PROXY"
    echo "Verify these settings are correct"
  else
    echo "No proxy settings found. If you're behind a corporate proxy, set HTTP_PROXY and HTTPS_PROXY"
  fi
  exit 1
fi

# check disk space
echo "Checking disk space..."
DOCKER_DIR=$(docker info | grep "Docker Root Dir" | cut -d: -f2 | tr -d '[:space:]')
AVAILABLE=$(df -h "$DOCKER_DIR" | awk 'NR==2 {print $4}')
echo "Available space in Docker directory: $AVAILABLE"

# prune unused resources
echo "Would you like to prune unused Docker resources? (y/n)"
read -r response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
  docker system prune -f
  echo "✅ Docker resources pruned"
fi

echo "✅ Troubleshooting complete"