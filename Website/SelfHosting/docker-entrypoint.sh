#!/bin/bash

# Docker Entrypoint for OpenClone Website
# Handles Let's Encrypt SSL certificate setup before starting the application

set -e

echo "Starting OpenClone Website container..."

# Generate Let's Encrypt certificate before starting web app
echo "Setting up Let's Encrypt SSL certificate..."
/app/setup-ssl.sh

# Set up certificate renewal cron job
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

echo "SSL setup complete, starting OpenClone application..."

# Start the .NET application
exec dotnet OpenClone.UI.dll