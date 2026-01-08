#!/bin/bash
set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Default values
DOMAIN="${DOMAIN:-localhost}"
DAYS="${DAYS:-365}"
KEY_SIZE="${KEY_SIZE:-2048}"
OUTPUT_DIR="${OUTPUT_DIR:-/certs}"
CERT_NAME="${CERT_NAME:-server}"
COUNTRY="${COUNTRY:-US}"
STATE="${STATE:-California}"
CITY="${CITY:-San Francisco}"
ORG="${ORG:-Development}"
ORG_UNIT="${ORG_UNIT:-IT}"
EMAIL="${EMAIL:-admin@localhost}"

# Parse additional domains for SAN
IFS=',' read -ra EXTRA_DOMAINS <<< "${ALT_NAMES:-}"

print_banner() {
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║              SSL Certificate Generator                        ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

generate_ca() {
    log_info "Generating Certificate Authority (CA)..."

    # Generate CA private key
    openssl genrsa -out "$OUTPUT_DIR/ca.key" $KEY_SIZE 2>/dev/null

    # Generate CA certificate
    openssl req -x509 -new -nodes \
        -key "$OUTPUT_DIR/ca.key" \
        -sha256 \
        -days $DAYS \
        -out "$OUTPUT_DIR/ca.crt" \
        -subj "/C=$COUNTRY/ST=$STATE/L=$CITY/O=$ORG/OU=$ORG_UNIT/CN=$ORG CA"

    log_info "CA certificate generated: ca.crt, ca.key"
}

generate_server_cert() {
    log_info "Generating server certificate for: $DOMAIN"

    # Create SAN config
    cat > "$OUTPUT_DIR/san.cnf" << EOF
[req]
default_bits = $KEY_SIZE
prompt = no
default_md = sha256
distinguished_name = dn
req_extensions = req_ext

[dn]
C = $COUNTRY
ST = $STATE
L = $CITY
O = $ORG
OU = $ORG_UNIT
CN = $DOMAIN
emailAddress = $EMAIL

[req_ext]
subjectAltName = @alt_names

[alt_names]
DNS.1 = $DOMAIN
DNS.2 = *.$DOMAIN
IP.1 = 127.0.0.1
IP.2 = ::1
EOF

    # Add extra domains to SAN
    dns_count=3
    ip_count=3
    for alt in "${EXTRA_DOMAINS[@]}"; do
        alt=$(echo "$alt" | xargs)  # trim whitespace
        if [[ $alt =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            echo "IP.$ip_count = $alt" >> "$OUTPUT_DIR/san.cnf"
            ((ip_count++))
        else
            echo "DNS.$dns_count = $alt" >> "$OUTPUT_DIR/san.cnf"
            ((dns_count++))
        fi
    done

    # Generate server private key
    openssl genrsa -out "$OUTPUT_DIR/$CERT_NAME.key" $KEY_SIZE 2>/dev/null

    # Generate CSR
    openssl req -new \
        -key "$OUTPUT_DIR/$CERT_NAME.key" \
        -out "$OUTPUT_DIR/$CERT_NAME.csr" \
        -config "$OUTPUT_DIR/san.cnf"

    # Create extension config for signing
    cat > "$OUTPUT_DIR/ext.cnf" << EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth, clientAuth
subjectAltName = @alt_names

[alt_names]
DNS.1 = $DOMAIN
DNS.2 = *.$DOMAIN
IP.1 = 127.0.0.1
IP.2 = ::1
EOF

    # Add extra domains
    dns_count=3
    ip_count=3
    for alt in "${EXTRA_DOMAINS[@]}"; do
        alt=$(echo "$alt" | xargs)
        if [[ $alt =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            echo "IP.$ip_count = $alt" >> "$OUTPUT_DIR/ext.cnf"
            ((ip_count++))
        else
            echo "DNS.$dns_count = $alt" >> "$OUTPUT_DIR/ext.cnf"
            ((dns_count++))
        fi
    done

    # Sign with CA
    openssl x509 -req \
        -in "$OUTPUT_DIR/$CERT_NAME.csr" \
        -CA "$OUTPUT_DIR/ca.crt" \
        -CAkey "$OUTPUT_DIR/ca.key" \
        -CAcreateserial \
        -out "$OUTPUT_DIR/$CERT_NAME.crt" \
        -days $DAYS \
        -sha256 \
        -extfile "$OUTPUT_DIR/ext.cnf" 2>/dev/null

    log_info "Server certificate generated: $CERT_NAME.crt, $CERT_NAME.key"
}

generate_combined() {
    log_info "Creating combined files..."

    # Create PEM bundle (cert + key)
    cat "$OUTPUT_DIR/$CERT_NAME.crt" "$OUTPUT_DIR/$CERT_NAME.key" > "$OUTPUT_DIR/$CERT_NAME.pem"

    # Create full chain (cert + ca)
    cat "$OUTPUT_DIR/$CERT_NAME.crt" "$OUTPUT_DIR/ca.crt" > "$OUTPUT_DIR/$CERT_NAME.fullchain.crt"

    # Create PKCS12 bundle
    openssl pkcs12 -export \
        -out "$OUTPUT_DIR/$CERT_NAME.p12" \
        -inkey "$OUTPUT_DIR/$CERT_NAME.key" \
        -in "$OUTPUT_DIR/$CERT_NAME.crt" \
        -certfile "$OUTPUT_DIR/ca.crt" \
        -passout pass:${P12_PASSWORD:-changeit} 2>/dev/null

    log_info "Combined files created: $CERT_NAME.pem, $CERT_NAME.fullchain.crt, $CERT_NAME.p12"
}

cleanup() {
    log_info "Cleaning up temporary files..."
    rm -f "$OUTPUT_DIR/san.cnf" "$OUTPUT_DIR/ext.cnf" "$OUTPUT_DIR/$CERT_NAME.csr" "$OUTPUT_DIR/ca.srl"
}

print_summary() {
    echo ""
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}Certificate Generation Complete!${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo "Generated files in $OUTPUT_DIR:"
    echo ""
    echo "  CA Certificate:"
    echo "    ca.crt              - CA certificate (install in browser/system)"
    echo "    ca.key              - CA private key (keep secure!)"
    echo ""
    echo "  Server Certificate:"
    echo "    $CERT_NAME.crt          - Server certificate"
    echo "    $CERT_NAME.key          - Server private key"
    echo "    $CERT_NAME.pem          - Combined cert + key"
    echo "    $CERT_NAME.fullchain.crt- Full chain (cert + CA)"
    echo "    $CERT_NAME.p12          - PKCS12 bundle (password: ${P12_PASSWORD:-changeit})"
    echo ""
    echo "Domain: $DOMAIN"
    echo "Valid for: $DAYS days"
    echo ""
    echo -e "${YELLOW}To trust the CA on macOS:${NC}"
    echo "  sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain $OUTPUT_DIR/ca.crt"
    echo ""
    echo -e "${YELLOW}To trust the CA on Linux:${NC}"
    echo "  sudo cp $OUTPUT_DIR/ca.crt /usr/local/share/ca-certificates/"
    echo "  sudo update-ca-certificates"
    echo ""
}

show_help() {
    echo "SSL Certificate Generator"
    echo ""
    echo "Usage: generate.sh [OPTIONS]"
    echo ""
    echo "Environment Variables:"
    echo "  DOMAIN        Primary domain name (default: localhost)"
    echo "  ALT_NAMES     Comma-separated list of additional domains/IPs"
    echo "  DAYS          Certificate validity in days (default: 365)"
    echo "  KEY_SIZE      RSA key size (default: 2048)"
    echo "  OUTPUT_DIR    Output directory (default: /certs)"
    echo "  CERT_NAME     Certificate filename prefix (default: server)"
    echo "  COUNTRY       Country code (default: US)"
    echo "  STATE         State/Province (default: California)"
    echo "  CITY          City (default: San Francisco)"
    echo "  ORG           Organization (default: Development)"
    echo "  ORG_UNIT      Organizational Unit (default: IT)"
    echo "  EMAIL         Email address (default: admin@localhost)"
    echo "  P12_PASSWORD  PKCS12 bundle password (default: changeit)"
    echo ""
    echo "Examples:"
    echo "  DOMAIN=myapp.local ./generate.sh"
    echo "  DOMAIN=api.example.com ALT_NAMES=www.example.com,192.168.1.100 ./generate.sh"
}

main() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        show_help
        exit 0
    fi

    print_banner

    mkdir -p "$OUTPUT_DIR"

    log_info "Domain: $DOMAIN"
    log_info "Validity: $DAYS days"
    log_info "Key size: $KEY_SIZE bits"
    log_info "Output: $OUTPUT_DIR"
    [[ -n "${ALT_NAMES:-}" ]] && log_info "Alt names: $ALT_NAMES"
    echo ""

    generate_ca
    generate_server_cert
    generate_combined
    cleanup
    print_summary
}

main "$@"
