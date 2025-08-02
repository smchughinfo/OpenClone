#!/bin/bash

# SSL Certificate Setup Script for OpenClone
# This script handles Let's Encrypt certificate generation and renewal

DOMAIN="${SSL_DOMAIN}"
EMAIL="${SSL_EMAIL}"
SSL_DIR="/app/ssl"

echo "Setting up Let's Encrypt SSL certificate for domain: $DOMAIN"

# Create SSL directory if it doesn't exist
mkdir -p $SSL_DIR

# Check if certificate already exists and is valid (unless force renewal is requested)
if [ "$FORCE_SSL_RENEWAL" != "true" ] && [ -f "$SSL_DIR/fullchain.pem" ] && [ -f "$SSL_DIR/privkey.pem" ]; then
    # Check if certificate is still valid (more than 30 days remaining)
    if openssl x509 -checkend 2592000 -noout -in "$SSL_DIR/fullchain.pem" >/dev/null 2>&1; then
        echo "Valid Let's Encrypt certificate found in persistent storage, skipping generation..."
        echo "Let's Encrypt certificate setup complete!"
        exit 0
    else
        echo "Certificate exists but expires soon, will renew..."
    fi
elif [ "$FORCE_SSL_RENEWAL" = "true" ]; then
    echo "Force renewal requested, regenerating certificate..."
fi

# Generate Let's Encrypt certificate using HTTP challenge on port 80
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
    echo "ERROR: Let's Encrypt certificate generation failed!"
    echo "Please ensure:"
    echo "  1. Domain $DOMAIN points to this server's public IP"
    echo "  2. Port 80 is accessible from the internet"
    echo "  3. No other service is using port 80"
    echo "  4. Server has internet connectivity"
    exit 1
fi