#!/bin/bash
# ================================================
# op-stack Build Script
# Builds all projects and Docker images
# ================================================

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Script directory (op-stack-deploy)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# Project root directory (parent of op-stack-deploy)
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  op-stack Build Script${NC}"
echo -e "${GREEN}========================================${NC}"
echo "Project root: $ROOT_DIR"
echo "Deploy dir:   $SCRIPT_DIR"

# Function to print step
step() {
    echo -e "\n${YELLOW}▶ $1${NC}"
}

# Function to print success
success() {
    echo -e "${GREEN}✓ $1${NC}"
}

# Function to print error
error() {
    echo -e "${RED}✗ $1${NC}"
    exit 1
}

# ============================================
# Step 1: Build Java Backend Services
# ============================================
step "Building Java backend services..."

# Build op-stack-service
echo "  Building op-stack-service..."
cd "$ROOT_DIR/op-stack-service"
mvn clean package -DskipTests -q || error "Failed to build op-stack-service"
success "op-stack-service built"

# Build op-stack-auth
echo "  Building op-stack-auth..."
cd "$ROOT_DIR/op-stack-auth"
mvn clean package -DskipTests -q || error "Failed to build op-stack-auth"
success "op-stack-auth built"

# Build op-stack-gateway
echo "  Building op-stack-gateway..."
cd "$ROOT_DIR/op-stack-gateway"
mvn clean package -DskipTests -q || error "Failed to build op-stack-gateway"
success "op-stack-gateway built"

# ============================================
# Step 2: Build Python Services (no pre-build needed)
# ============================================
step "Python services (executor, tools) will be built during docker build..."

# ============================================
# Step 3: Build Frontend
# ============================================
step "Building frontend..."

cd "$ROOT_DIR/op-stack-web"

# Install dependencies if node_modules doesn't exist
if [ ! -d "node_modules" ]; then
    echo "  Installing npm dependencies..."
    npm install --silent || error "Failed to install npm dependencies"
fi

# Set API URL for build
export VITE_API_BASE_URL="${VITE_API_BASE_URL:-http://localhost:8080}"
echo "  Building with VITE_API_BASE_URL=$VITE_API_BASE_URL"

npm run build --silent || error "Failed to build frontend"
success "Frontend built"

# ============================================
# Step 4: Build Docker Images
# ============================================
step "Building Docker images..."

cd "$SCRIPT_DIR"

# Build all images with docker-compose
docker-compose build || error "Failed to build Docker images"

success "All Docker images built"

# ============================================
# Summary
# ============================================
echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}  Build Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Next steps:"
echo "  1. cd $SCRIPT_DIR"
echo "  2. cp .env.example .env  (and configure)"
echo "  3. docker-compose up -d"
echo "  4. Access: http://localhost:3000"
echo ""
echo "Built images:"
docker images | grep op-stack | head -10
