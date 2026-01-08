#!/bin/bash
set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Default options
DRY_RUN=false
FORCE=false
VERBOSE=false
CLEAN_IMAGES=true
CLEAN_CONTAINERS=true
CLEAN_VOLUMES=true
CLEAN_NETWORKS=true
CLEAN_BUILD_CACHE=true
KEEP_RECENT_HOURS=24

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_debug() { [[ "$VERBOSE" == "true" ]] && echo -e "${CYAN}[DEBUG]${NC} $1"; }

print_banner() {
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                   Docker Cleanup Tool                         ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

show_help() {
    echo "Docker Cleanup Tool - Clean up Docker resources safely"
    echo ""
    echo "Usage: docker-cleanup [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -a, --all              Clean all resources (default)"
    echo "  -i, --images           Clean dangling and unused images"
    echo "  -c, --containers       Clean stopped containers"
    echo "  -v, --volumes          Clean dangling volumes"
    echo "  -n, --networks         Clean unused networks"
    echo "  -b, --build-cache      Clean build cache"
    echo "  -d, --dry-run          Show what would be deleted without deleting"
    echo "  -f, --force            Skip confirmation prompts"
    echo "  -k, --keep-hours N     Keep images used in last N hours (default: 24)"
    echo "  --verbose              Show detailed output"
    echo "  -h, --help             Show this help message"
    echo ""
    echo "Examples:"
    echo "  docker-cleanup --dry-run        # Preview what would be cleaned"
    echo "  docker-cleanup -a -f            # Clean everything without prompts"
    echo "  docker-cleanup -i -v            # Clean only images and volumes"
    echo "  docker-cleanup --keep-hours 48  # Keep images used in last 48 hours"
}

format_size() {
    local size=$1
    if [[ $size -ge 1073741824 ]]; then
        echo "$(awk "BEGIN {printf \"%.2f\", $size/1073741824}")GB"
    elif [[ $size -ge 1048576 ]]; then
        echo "$(awk "BEGIN {printf \"%.2f\", $size/1048576}")MB"
    elif [[ $size -ge 1024 ]]; then
        echo "$(awk "BEGIN {printf \"%.2f\", $size/1024}")KB"
    else
        echo "${size}B"
    fi
}

get_disk_usage() {
    docker system df --format "{{.Size}}" 2>/dev/null | head -1 || echo "N/A"
}

confirm() {
    local message=$1
    if [[ "$FORCE" == "true" ]]; then
        return 0
    fi
    echo -en "${YELLOW}$message [y/N]: ${NC}"
    read -r response
    [[ "$response" =~ ^[Yy]$ ]]
}

clean_containers() {
    log_info "Cleaning stopped containers..."

    local containers
    containers=$(docker ps -aq --filter "status=exited" --filter "status=dead" --filter "status=created" 2>/dev/null || true)

    if [[ -z "$containers" ]]; then
        log_info "No stopped containers to clean"
        return 0
    fi

    local count
    count=$(echo "$containers" | wc -l | tr -d ' ')
    log_info "Found $count stopped container(s)"

    if [[ "$DRY_RUN" == "true" ]]; then
        log_warn "[DRY RUN] Would remove $count container(s)"
        [[ "$VERBOSE" == "true" ]] && docker ps -a --filter "status=exited" --filter "status=dead" --filter "status=created" --format "table {{.ID}}\t{{.Image}}\t{{.Status}}"
    else
        docker container prune -f
        log_info "Removed $count container(s)"
    fi
}

clean_images() {
    log_info "Cleaning unused images..."

    # Dangling images (untagged)
    local dangling
    dangling=$(docker images -q --filter "dangling=true" 2>/dev/null || true)

    if [[ -n "$dangling" ]]; then
        local count
        count=$(echo "$dangling" | wc -l | tr -d ' ')
        log_info "Found $count dangling image(s)"

        if [[ "$DRY_RUN" == "true" ]]; then
            log_warn "[DRY RUN] Would remove $count dangling image(s)"
        else
            docker image prune -f
            log_info "Removed dangling images"
        fi
    else
        log_info "No dangling images to clean"
    fi

    # Unused images (not referenced by any container)
    local unused
    unused=$(docker images -q --filter "dangling=false" 2>/dev/null || true)

    if [[ -n "$unused" ]]; then
        local total_unused
        total_unused=$(echo "$unused" | wc -l | tr -d ' ')
        log_debug "Found $total_unused total images"

        if [[ "$DRY_RUN" == "true" ]]; then
            log_warn "[DRY RUN] Would analyze unused images"
        else
            # Use --all to remove all unused images
            docker image prune -af --filter "until=${KEEP_RECENT_HOURS}h" 2>/dev/null || true
            log_info "Cleaned unused images older than ${KEEP_RECENT_HOURS}h"
        fi
    fi
}

clean_volumes() {
    log_info "Cleaning dangling volumes..."

    local volumes
    volumes=$(docker volume ls -q --filter "dangling=true" 2>/dev/null || true)

    if [[ -z "$volumes" ]]; then
        log_info "No dangling volumes to clean"
        return 0
    fi

    local count
    count=$(echo "$volumes" | wc -l | tr -d ' ')
    log_info "Found $count dangling volume(s)"

    if [[ "$DRY_RUN" == "true" ]]; then
        log_warn "[DRY RUN] Would remove $count volume(s)"
        [[ "$VERBOSE" == "true" ]] && docker volume ls --filter "dangling=true"
    else
        docker volume prune -f
        log_info "Removed $count volume(s)"
    fi
}

clean_networks() {
    log_info "Cleaning unused networks..."

    local networks
    networks=$(docker network ls -q --filter "type=custom" 2>/dev/null || true)

    if [[ -z "$networks" ]]; then
        log_info "No custom networks found"
        return 0
    fi

    if [[ "$DRY_RUN" == "true" ]]; then
        log_warn "[DRY RUN] Would clean unused networks"
    else
        docker network prune -f
        log_info "Cleaned unused networks"
    fi
}

clean_build_cache() {
    log_info "Cleaning build cache..."

    if [[ "$DRY_RUN" == "true" ]]; then
        local cache_size
        cache_size=$(docker system df --format "{{.Size}}" 2>/dev/null | tail -1 || echo "N/A")
        log_warn "[DRY RUN] Would clean build cache (current size: $cache_size)"
    else
        docker builder prune -f --filter "until=${KEEP_RECENT_HOURS}h" 2>/dev/null || true
        log_info "Cleaned build cache older than ${KEEP_RECENT_HOURS}h"
    fi
}

show_summary() {
    echo ""
    echo -e "${BLUE}=== Docker Disk Usage ===${NC}"
    docker system df 2>/dev/null || echo "Unable to get disk usage"
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -a|--all)
            CLEAN_IMAGES=true
            CLEAN_CONTAINERS=true
            CLEAN_VOLUMES=true
            CLEAN_NETWORKS=true
            CLEAN_BUILD_CACHE=true
            shift
            ;;
        -i|--images)
            CLEAN_IMAGES=true
            CLEAN_CONTAINERS=false
            CLEAN_VOLUMES=false
            CLEAN_NETWORKS=false
            CLEAN_BUILD_CACHE=false
            shift
            ;;
        -c|--containers)
            CLEAN_CONTAINERS=true
            shift
            ;;
        -v|--volumes)
            CLEAN_VOLUMES=true
            shift
            ;;
        -n|--networks)
            CLEAN_NETWORKS=true
            shift
            ;;
        -b|--build-cache)
            CLEAN_BUILD_CACHE=true
            shift
            ;;
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -f|--force)
            FORCE=true
            shift
            ;;
        -k|--keep-hours)
            KEEP_RECENT_HOURS="$2"
            shift 2
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

main() {
    print_banner

    # Check Docker is running
    if ! docker info >/dev/null 2>&1; then
        log_error "Docker is not running or not accessible"
        exit 1
    fi

    log_info "Starting Docker cleanup..."
    [[ "$DRY_RUN" == "true" ]] && log_warn "DRY RUN MODE - No changes will be made"
    echo ""

    # Show current usage
    log_info "Current Docker disk usage:"
    docker system df 2>/dev/null || true
    echo ""

    # Confirm if not forced
    if [[ "$DRY_RUN" != "true" ]] && ! confirm "Proceed with cleanup?"; then
        log_info "Cleanup cancelled"
        exit 0
    fi

    echo ""

    # Run cleanup
    [[ "$CLEAN_CONTAINERS" == "true" ]] && clean_containers
    [[ "$CLEAN_IMAGES" == "true" ]] && clean_images
    [[ "$CLEAN_VOLUMES" == "true" ]] && clean_volumes
    [[ "$CLEAN_NETWORKS" == "true" ]] && clean_networks
    [[ "$CLEAN_BUILD_CACHE" == "true" ]] && clean_build_cache

    # Show summary
    if [[ "$DRY_RUN" != "true" ]]; then
        show_summary
    fi

    echo ""
    log_info "Cleanup complete!"
}

main "$@"
