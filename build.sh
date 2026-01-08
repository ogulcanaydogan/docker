#!/bin/bash
set -e

# Docker Hub username
DOCKER_USER="ogulcanaydogan"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# Images to build (directory name = image name)
IMAGES=(
    "db-backup"
    "devbox"
    "env-validator"
    "ssl-gen"
    "fastapi-starter"
    "express-starter"
    "docker-cleanup"
    "healthcheck"
    "wait-for-it"
)

# Note: db-toolkit is docker-compose only, no image to build

log() { echo -e "${GREEN}[BUILD]${NC} $1"; }
header() { echo -e "\n${BLUE}═══════════════════════════════════════${NC}"; echo -e "${BLUE}  $1${NC}"; echo -e "${BLUE}═══════════════════════════════════════${NC}\n"; }

show_help() {
    echo "Docker Build & Push Script"
    echo ""
    echo "Usage: ./build.sh [OPTIONS] [IMAGE...]"
    echo ""
    echo "Options:"
    echo "  --push       Push images to Docker Hub after building"
    echo "  --all        Build all images (default if no image specified)"
    echo "  --list       List available images"
    echo "  -h, --help   Show this help"
    echo ""
    echo "Examples:"
    echo "  ./build.sh                      # Build all images"
    echo "  ./build.sh --push               # Build and push all images"
    echo "  ./build.sh db-backup            # Build only db-backup"
    echo "  ./build.sh --push db-backup     # Build and push db-backup"
    echo "  ./build.sh healthcheck wait-for-it  # Build multiple images"
}

list_images() {
    echo "Available images:"
    for img in "${IMAGES[@]}"; do
        echo "  - $DOCKER_USER/$img"
    done
    echo ""
    echo "Note: db-toolkit is docker-compose only (no image)"
}

build_image() {
    local name=$1
    local full_name="$DOCKER_USER/$name"

    if [[ ! -d "$name" ]]; then
        echo "Error: Directory $name not found"
        return 1
    fi

    if [[ ! -f "$name/Dockerfile" ]]; then
        echo "Skipping $name (no Dockerfile)"
        return 0
    fi

    header "Building $full_name"

    docker build -t "$full_name:latest" "./$name"

    log "Successfully built $full_name"
}

push_image() {
    local name=$1
    local full_name="$DOCKER_USER/$name"

    header "Pushing $full_name"

    docker push "$full_name:latest"

    log "Successfully pushed $full_name"
}

# Parse arguments
PUSH=false
BUILD_IMAGES=()

while [[ $# -gt 0 ]]; do
    case $1 in
        --push)
            PUSH=true
            shift
            ;;
        --all)
            BUILD_IMAGES=("${IMAGES[@]}")
            shift
            ;;
        --list)
            list_images
            exit 0
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        -*)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
        *)
            BUILD_IMAGES+=("$1")
            shift
            ;;
    esac
done

# Default to all images if none specified
if [[ ${#BUILD_IMAGES[@]} -eq 0 ]]; then
    BUILD_IMAGES=("${IMAGES[@]}")
fi

# Main execution
cd "$(dirname "$0")"

echo ""
echo "Docker Hub User: $DOCKER_USER"
echo "Images to build: ${BUILD_IMAGES[*]}"
echo "Push to Hub: $PUSH"
echo ""

# Build images
for img in "${BUILD_IMAGES[@]}"; do
    build_image "$img"
done

# Push if requested
if [[ "$PUSH" == "true" ]]; then
    echo ""
    log "Logging in to Docker Hub..."
    docker login

    for img in "${BUILD_IMAGES[@]}"; do
        if [[ -f "$img/Dockerfile" ]]; then
            push_image "$img"
        fi
    done
fi

header "Complete!"
echo "Built images:"
for img in "${BUILD_IMAGES[@]}"; do
    if [[ -f "$img/Dockerfile" ]]; then
        echo "  ✓ $DOCKER_USER/$img"
    fi
done
echo ""
