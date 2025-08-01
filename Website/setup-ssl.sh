#!/bin/bash

# SSL Certificate Setup Script for OpenClone
# This script handles both self-signed and Let's Encrypt certificates

DOMAIN="${SSL_DOMAIN:-app.clonezone.me}"
EMAIL="${SSL_EMAIL:-admin@clonezone.me}"
SSL_DIR="/app/ssl"
USE_LETSENCRYPT="${USE_LETSENCRYPT:-false}"

echo "Setting up SSL certificate for domain: $DOMAIN"

# Create SSL directory if it doesn't exist
mkdir -p $SSL_DIR

if [ "$USE_LETSENCRYPT" = "true" ]; then
    echo "Attempting Let's Encrypt certificate generation..."
    
    # Check if certificate already exists and is valid
    if [ -f "/etc/letsencrypt/live/$DOMAIN/fullchain.pem" ]; then
        # Check if certificate is still valid (more than 30 days remaining)
        if openssl x509 -checkend 2592000 -noout -in "/etc/letsencrypt/live/$DOMAIN/fullchain.pem" >/dev/null 2>&1; then
            echo "Valid Let's Encrypt certificate found, copying to app directory..."
            cp "/etc/letsencrypt/live/$DOMAIN/fullchain.pem" "$SSL_DIR/"
            cp "/etc/letsencrypt/live/$DOMAIN/privkey.pem" "$SSL_DIR/"
            echo "Let's Encrypt certificate setup complete!"
            exit 0
        else
            echo "Certificate exists but expires soon, will renew..."
        fi
    fi
    
    # Try to get Let's Encrypt certificate using HTTP challenge on port 80
    echo "Generating Let's Encrypt certificate..."
    certbot certonly \
        --standalone \
        --non-interactive \
        --agree-tos \
        --email "$EMAIL" \
        --domains "$DOMAIN" \
        --preferred-challenges http \
        --http-01-port 80 \
        --keep-until-expiring
    
    if [ $? -eq 0 ] && [ -f "/etc/letsencrypt/live/$DOMAIN/fullchain.pem" ]; then
        echo "Let's Encrypt certificate generated successfully!"
        cp "/etc/letsencrypt/live/$DOMAIN/fullchain.pem" "$SSL_DIR/"
        cp "/etc/letsencrypt/live/$DOMAIN/privkey.pem" "$SSL_DIR/"
        echo "Let's Encrypt certificate setup complete!"
        exit 0
    else
        echo "Let's Encrypt certificate generation failed, falling back to self-signed certificate..."
    fi
fi

# Generate self-signed certificate as fallback
echo "Generating self-signed certificate for $DOMAIN..."

# Generate private key
openssl genrsa -out "$SSL_DIR/privkey.pem" 2048

# Generate certificate signing request
openssl req -new -key "$SSL_DIR/privkey.pem" -out "$SSL_DIR/cert.csr" \
    -subj "/C=US/ST=State/L=City/O=OpenClone/CN=$DOMAIN"

# Generate self-signed certificate with SAN extension
openssl x509 -req -in "$SSL_DIR/cert.csr" \
    -signkey "$SSL_DIR/privkey.pem" \
    -out "$SSL_DIR/fullchain.pem" \
    -days 365 \
    -extensions v3_req \
    -extfile <(cat <<EOF
[req]
distinguished_name = req_distinguished_name
req_extensions = v3_req
prompt = no

[req_distinguished_name]
C = US
ST = State
L = City
O = OpenClone
CN = $DOMAIN

[v3_req]
keyUsage = keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[alt_names]
DNS.1 = $DOMAIN
DNS.2 = localhost
DNS.3 = *.clonezone.me
IP.1 = 127.0.0.1
IP.2 = ::1
EOF
)

# Clean up CSR file
rm "$SSL_DIR/cert.csr"

# Set proper permissions
chmod 644 "$SSL_DIR/fullchain.pem"
chmod 600 "$SSL_DIR/privkey.pem"

echo "Self-signed certificate generated successfully!"
echo "Files created:"
echo "  - $SSL_DIR/privkey.pem (private key)"
echo "  - $SSL_DIR/fullchain.pem (certificate)"
echo ""
echo "Note: Self-signed certificates will show browser warnings."
echo "To use Let's Encrypt instead, set environment variables:"
echo "  USE_LETSENCRYPT=true"
echo "  SSL_DOMAIN=your-domain.com"
echo "  SSL_EMAIL=your-email@domain.com"