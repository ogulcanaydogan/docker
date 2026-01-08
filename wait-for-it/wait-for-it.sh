#!/bin/bash
# wait-for-it.sh - Wait for multiple services to be ready

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Default values
TIMEOUT=30
INTERVAL=1
QUIET=false
STRICT=false
PARALLEL=false

# Arrays for targets
TARGETS=()
COMMAND=()

log_info() { [[ "$QUIET" != "true" ]] && echo -e "${GREEN}[✓]${NC} $1"; }
log_wait() { [[ "$QUIET" != "true" ]] && echo -e "${YELLOW}[...]${NC} $1"; }
log_error() { [[ "$QUIET" != "true" ]] && echo -e "${RED}[✗]${NC} $1"; }
log_debug() { [[ "$QUIET" != "true" ]] && [[ "$VERBOSE" == "true" ]] && echo -e "${CYAN}[DEBUG]${NC} $1"; }

show_help() {
    echo "wait-for-it - Wait for services to be available"
    echo ""
    echo "Usage: wait-for-it [OPTIONS] [HOST:PORT...] [-- COMMAND]"
    echo ""
    echo "Options:"
    echo "  -h, --host HOST:PORT     Host and port to wait for (can be repeated)"
    echo "  -t, --timeout SECONDS    Timeout in seconds (default: 30, 0 = infinite)"
    echo "  -i, --interval SECONDS   Check interval in seconds (default: 1)"
    echo "  -p, --parallel           Check all hosts in parallel"
    echo "  -s, --strict             Exit immediately if a host is unavailable"
    echo "  -q, --quiet              Suppress output"
    echo "  -v, --verbose            Show detailed output"
    echo "  --help                   Show this help message"
    echo ""
    echo "  --                       Execute command after services are ready"
    echo ""
    echo "Examples:"
    echo "  wait-for-it db:5432"
    echo "  wait-for-it db:5432 redis:6379 -- npm start"
    echo "  wait-for-it -t 60 -h db:5432 -h redis:6379"
    echo "  wait-for-it --parallel db:5432 redis:6379 api:8080"
    echo ""
    echo "Environment Variables:"
    echo "  WAIT_HOSTS       Comma-separated list of host:port pairs"
    echo "  WAIT_TIMEOUT     Timeout in seconds"
    echo "  WAIT_INTERVAL    Check interval in seconds"
    echo "  WAIT_COMMAND     Command to run after services are ready"
}

wait_for_host() {
    local target=$1
    local host="${target%:*}"
    local port="${target#*:}"

    if [[ "$host" == "$port" ]] || [[ -z "$port" ]]; then
        log_error "Invalid target format: $target (expected HOST:PORT)"
        return 1
    fi

    local start_time=$(date +%s)
    local end_time=$((start_time + TIMEOUT))

    log_wait "Waiting for $host:$port..."

    while true; do
        if nc -z -w 1 "$host" "$port" 2>/dev/null; then
            log_info "$host:$port is available"
            return 0
        fi

        local current_time=$(date +%s)

        if [[ "$TIMEOUT" -gt 0 ]] && [[ "$current_time" -ge "$end_time" ]]; then
            log_error "$host:$port is not available after ${TIMEOUT}s"
            return 1
        fi

        log_debug "Waiting for $host:$port... ($(( end_time - current_time ))s remaining)"
        sleep "$INTERVAL"
    done
}

wait_parallel() {
    local pids=()
    local results=()
    local failed=0

    # Start all checks in background
    for target in "${TARGETS[@]}"; do
        (
            wait_for_host "$target"
        ) &
        pids+=($!)
    done

    # Wait for all to complete
    for i in "${!pids[@]}"; do
        if ! wait "${pids[$i]}"; then
            ((failed++))
            if [[ "$STRICT" == "true" ]]; then
                # Kill remaining processes
                for pid in "${pids[@]}"; do
                    kill "$pid" 2>/dev/null || true
                done
                return 1
            fi
        fi
    done

    return $failed
}

wait_sequential() {
    for target in "${TARGETS[@]}"; do
        if ! wait_for_host "$target"; then
            if [[ "$STRICT" == "true" ]]; then
                return 1
            fi
        fi
    done
    return 0
}

# Parse environment variables
if [[ -n "$WAIT_HOSTS" ]]; then
    IFS=',' read -ra ENV_HOSTS <<< "$WAIT_HOSTS"
    for host in "${ENV_HOSTS[@]}"; do
        TARGETS+=("$(echo "$host" | xargs)")
    done
fi

[[ -n "$WAIT_TIMEOUT" ]] && TIMEOUT="$WAIT_TIMEOUT"
[[ -n "$WAIT_INTERVAL" ]] && INTERVAL="$WAIT_INTERVAL"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--host)
            TARGETS+=("$2")
            shift 2
            ;;
        -t|--timeout)
            TIMEOUT="$2"
            shift 2
            ;;
        -i|--interval)
            INTERVAL="$2"
            shift 2
            ;;
        -p|--parallel)
            PARALLEL=true
            shift
            ;;
        -s|--strict)
            STRICT=true
            shift
            ;;
        -q|--quiet)
            QUIET=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        --help)
            show_help
            exit 0
            ;;
        --)
            shift
            COMMAND=("$@")
            break
            ;;
        -*)
            log_error "Unknown option: $1"
            show_help
            exit 1
            ;;
        *)
            # Treat as host:port
            TARGETS+=("$1")
            shift
            ;;
    esac
done

# Check for command from environment
if [[ ${#COMMAND[@]} -eq 0 ]] && [[ -n "$WAIT_COMMAND" ]]; then
    COMMAND=("bash" "-c" "$WAIT_COMMAND")
fi

# Validate targets
if [[ ${#TARGETS[@]} -eq 0 ]]; then
    log_error "No targets specified"
    show_help
    exit 1
fi

# Main execution
[[ "$QUIET" != "true" ]] && echo -e "${CYAN}wait-for-it${NC} - Waiting for ${#TARGETS[@]} service(s)"
log_debug "Targets: ${TARGETS[*]}"
log_debug "Timeout: ${TIMEOUT}s, Interval: ${INTERVAL}s"
log_debug "Mode: $([ "$PARALLEL" == "true" ] && echo "parallel" || echo "sequential")"

# Wait for services
if [[ "$PARALLEL" == "true" ]]; then
    wait_parallel
    result=$?
else
    wait_sequential
    result=$?
fi

if [[ $result -ne 0 ]]; then
    log_error "Some services failed to become available"
    exit 1
fi

[[ "$QUIET" != "true" ]] && echo -e "${GREEN}All services are available!${NC}"

# Execute command if provided
if [[ ${#COMMAND[@]} -gt 0 ]]; then
    [[ "$QUIET" != "true" ]] && echo -e "${CYAN}Executing:${NC} ${COMMAND[*]}"
    exec "${COMMAND[@]}"
fi
