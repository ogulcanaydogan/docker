#!/bin/bash
set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Default values
TIMEOUT=5
RETRIES=1
RETRY_INTERVAL=1
EXPECTED_STATUS=200
VERBOSE=false
QUIET=false
METHOD="GET"
HEADERS=()
BODY=""

log_info() { [[ "$QUIET" != "true" ]] && echo -e "${GREEN}[OK]${NC} $1"; }
log_warn() { [[ "$QUIET" != "true" ]] && echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { [[ "$QUIET" != "true" ]] && echo -e "${RED}[FAIL]${NC} $1"; }
log_debug() { [[ "$VERBOSE" == "true" ]] && echo -e "${CYAN}[DEBUG]${NC} $1"; }

show_help() {
    echo "Universal Health Check Tool"
    echo ""
    echo "Usage: healthcheck [OPTIONS] <URL|HOST:PORT>"
    echo ""
    echo "Modes:"
    echo "  HTTP/HTTPS:  healthcheck http://localhost:8080/health"
    echo "  TCP:         healthcheck --tcp localhost:5432"
    echo ""
    echo "Options:"
    echo "  -t, --timeout SECONDS    Connection timeout (default: 5)"
    echo "  -r, --retries N          Number of retries (default: 1)"
    echo "  -i, --interval SECONDS   Interval between retries (default: 1)"
    echo "  -s, --status CODE        Expected HTTP status code (default: 200)"
    echo "  -m, --method METHOD      HTTP method (default: GET)"
    echo "  -H, --header HEADER      Add HTTP header (can be used multiple times)"
    echo "  -d, --data DATA          Request body for POST/PUT"
    echo "  --tcp                    Use TCP mode instead of HTTP"
    echo "  --contains TEXT          Response must contain TEXT"
    echo "  -v, --verbose            Show detailed output"
    echo "  -q, --quiet              Only output exit code"
    echo "  -h, --help               Show this help message"
    echo ""
    echo "Exit Codes:"
    echo "  0  Health check passed"
    echo "  1  Health check failed"
    echo "  2  Invalid arguments"
    echo ""
    echo "Examples:"
    echo "  healthcheck http://localhost:8080/health"
    echo "  healthcheck --tcp localhost:5432"
    echo "  healthcheck -s 201 -t 10 http://api.example.com/status"
    echo "  healthcheck -r 3 -i 2 --contains '\"status\":\"ok\"' http://localhost/api"
    echo "  healthcheck -m POST -d '{\"test\":true}' -H 'Content-Type: application/json' http://localhost/api"
}

check_http() {
    local url=$1
    local attempt=1

    while [[ $attempt -le $RETRIES ]]; do
        log_debug "Attempt $attempt of $RETRIES"

        # Build curl command
        local curl_args=("-s" "-o" "/tmp/response" "-w" "%{http_code}" "--connect-timeout" "$TIMEOUT" "-X" "$METHOD")

        # Add headers
        for header in "${HEADERS[@]}"; do
            curl_args+=("-H" "$header")
        done

        # Add body if provided
        if [[ -n "$BODY" ]]; then
            curl_args+=("-d" "$BODY")
        fi

        curl_args+=("$url")

        log_debug "curl ${curl_args[*]}"

        local status_code
        status_code=$(curl "${curl_args[@]}" 2>/dev/null || echo "000")

        log_debug "Response status: $status_code"

        # Check status code
        if [[ "$status_code" == "$EXPECTED_STATUS" ]]; then
            # Check content if required
            if [[ -n "$CONTAINS" ]]; then
                if grep -q "$CONTAINS" /tmp/response 2>/dev/null; then
                    log_info "HTTP $status_code - Response contains expected text"
                    [[ "$VERBOSE" == "true" ]] && cat /tmp/response
                    return 0
                else
                    log_debug "Response does not contain: $CONTAINS"
                fi
            else
                log_info "HTTP $status_code - $url"
                [[ "$VERBOSE" == "true" ]] && cat /tmp/response
                return 0
            fi
        else
            log_debug "Expected $EXPECTED_STATUS, got $status_code"
        fi

        if [[ $attempt -lt $RETRIES ]]; then
            log_debug "Waiting ${RETRY_INTERVAL}s before retry..."
            sleep "$RETRY_INTERVAL"
        fi

        ((attempt++))
    done

    log_error "HTTP check failed for $url (status: $status_code, expected: $EXPECTED_STATUS)"
    return 1
}

check_tcp() {
    local target=$1
    local host="${target%:*}"
    local port="${target#*:}"

    if [[ "$host" == "$port" ]]; then
        log_error "Invalid format. Use HOST:PORT"
        return 2
    fi

    local attempt=1

    while [[ $attempt -le $RETRIES ]]; do
        log_debug "Attempt $attempt of $RETRIES - TCP $host:$port"

        if nc -z -w "$TIMEOUT" "$host" "$port" 2>/dev/null; then
            log_info "TCP $host:$port is open"
            return 0
        fi

        if [[ $attempt -lt $RETRIES ]]; then
            log_debug "Waiting ${RETRY_INTERVAL}s before retry..."
            sleep "$RETRY_INTERVAL"
        fi

        ((attempt++))
    done

    log_error "TCP check failed for $host:$port"
    return 1
}

# Parse arguments
TCP_MODE=false
CONTAINS=""
TARGET=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -t|--timeout)
            TIMEOUT="$2"
            shift 2
            ;;
        -r|--retries)
            RETRIES="$2"
            shift 2
            ;;
        -i|--interval)
            RETRY_INTERVAL="$2"
            shift 2
            ;;
        -s|--status)
            EXPECTED_STATUS="$2"
            shift 2
            ;;
        -m|--method)
            METHOD="$2"
            shift 2
            ;;
        -H|--header)
            HEADERS+=("$2")
            shift 2
            ;;
        -d|--data)
            BODY="$2"
            shift 2
            ;;
        --tcp)
            TCP_MODE=true
            shift
            ;;
        --contains)
            CONTAINS="$2"
            shift 2
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -q|--quiet)
            QUIET=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        -*)
            log_error "Unknown option: $1"
            show_help
            exit 2
            ;;
        *)
            TARGET="$1"
            shift
            ;;
    esac
done

# Main execution
if [[ -z "$TARGET" ]]; then
    log_error "No target specified"
    show_help
    exit 2
fi

log_debug "Target: $TARGET"
log_debug "Mode: $([ "$TCP_MODE" == "true" ] && echo "TCP" || echo "HTTP")"
log_debug "Timeout: ${TIMEOUT}s, Retries: $RETRIES"

if [[ "$TCP_MODE" == "true" ]]; then
    check_tcp "$TARGET"
else
    check_http "$TARGET"
fi
