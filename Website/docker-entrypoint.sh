#!/bin/bash

# Docker Entrypoint for OpenClone Website
# Handles SSL certificate setup before starting the application

set -e

echo "Starting OpenClone Website container..."

# For Let's Encrypt, we need to generate certificates before starting the web app
if [ "$USE_LETSENCRYPT" = "true" ]; then
    echo "Let's Encrypt mode enabled, generating certificate before starting web application..."
    /app/setup-ssl.sh
elif [ ! -f "/app/ssl/fullchain.pem" ] || [ ! -f "/app/ssl/privkey.pem" ]; then
    echo "SSL certificate not found, generating self-signed certificate..."
    /app/setup-ssl.sh
else
    echo "SSL certificate found, checking validity..."
    
    # Check if certificate is still valid (more than 7 days remaining)
    if ! openssl x509 -checkend 604800 -noout -in "/app/ssl/fullchain.pem" >/dev/null 2>&1; then
        echo "SSL certificate expires soon, regenerating..."
        /app/setup-ssl.sh
    else
        echo "SSL certificate is valid."
    fi
fi

# Set up certificate renewal cron job if using Let's Encrypt
if [ "$USE_LETSENCRYPT" = "true" ]; then
    echo "Setting up certificate renewal cron job..."
    
    # Create renewal script
    cat > /app/renew-cert.sh << 'EOF'
#!/bin/bash
certbot renew --quiet --deploy-hook "/app/setup-ssl.sh"
EOF
    chmod +x /app/renew-cert.sh
    
    # Add to crontab (runs twice daily)
    (crontab -l 2>/dev/null; echo "0 12,0 * * * /app/renew-cert.sh") | crontab -
    
    # Start cron daemon in background
    cron
fi

echo "SSL setup complete, starting OpenClone application..."

# Start the .NET application
exec dotnet OpenClone.UI.dll