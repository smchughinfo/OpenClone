# Website - Core OpenClone Web Application

<div align="center">

![Landing Page](/Documentation/website-1.png)
![Clone Manager](/Documentation/website-2.png)
![Chat Interface](/Documentation/website-3.png)
![Q&A Training](/Documentation/website-4.png)

</div>

## What is this?

This is the main OpenClone web application built with .NET 8 ASP.NET Core. It provides the user interface and orchestrates all backend services including authentication, clone management, Q&A training, chat interfaces, and deepfake video generation. The application uses a hybrid architecture combining Razor Pages for server-side rendering with React components for interactive features.

The website coordinates all OpenClone services (Database, SadTalker, U-2-Net, ElevenLabs, OpenAI) and provides role-based access control, Google OAuth authentication, and real-time chat via SignalR.

## Container

Build container: `docker build --no-cache -t openclone-website:1.0 .`

Set all required environment variables (see complete list below). The application requires database connections, API keys for external services, JWT configuration, and service host addresses.

## Setup Requirements

**IMPORTANT**: Before running the website, install npm dependencies and build webpack bundles:

```bash
cd OpenClone.UI
npm install
npm run build
```

If you see 404 errors for JavaScript bundles or React components don't work, run the commands above.

## How to run it

Set required environment variables (see root README.md for complete list). Run the container using `/StartStopScripts/Website/start.bat` or start manually with the docker command. The application runs on port 8080 and requires SadTalker and U-2-Net services to be running for full functionality.

### Service Communication Issue with SSL

**IMPORTANT**: When using SSL self-hosting, the website container cannot reach other services using `127.0.0.1` addresses. You must use your host computer's LAN IP address instead.

**Required environment variable changes:**
```bash
# Instead of localhost addresses:
# OpenClone_SadTalker_HostAddress=http://127.0.0.1:5001
# OpenClone_U2Net_HostAddress=http://127.0.0.1:5002

# Use your host computer's LAN IP address:
OpenClone_SadTalker_HostAddress=http://192.168.0.100:5001    # Replace with your actual IP
OpenClone_U2Net_HostAddress=http://192.168.0.100:5002       # Replace with your actual IP
```

**To find your IP address:**
- Windows: `ipconfig` (look for IPv4 Address)
- Linux/Mac: `ip addr` or `ifconfig`

**Why this happens**: The SSL container setup appears to break Docker's default bridge networking for `127.0.0.1` inter-container communication. Using the host's LAN IP address works around this limitation.

## HTTPS Self-Hosting

The website includes built-in HTTPS support with automatic Let's Encrypt SSL certificate management for self-hosting scenarios where you want to expose OpenClone to the internet with proper SSL encryption.

### Features
- **Automatic Let's Encrypt SSL certificates** - production-ready trusted certificates
- **Certificate renewal** with automated cron jobs inside container
- **Smart certificate validation** and regeneration when needed
- **Force renewal option** for certificate troubleshooting
- **Persistent certificate storage** via Docker volume mounts

### Configuration

**Required Environment Variables**:
```bash
OpenClone_Self_Hosting_Domain=your-domain.com    # Your domain name
OpenClone_Admin_Email=admin@your-domain.com      # Email for Let's Encrypt registration
```

**Optional Environment Variables**:
```bash
FORCE_SSL_RENEWAL=true    # Forces certificate regeneration (use sparingly)
```

### Usage

1. **Set up DNS** - Point your domain to your server's public IP
2. **Configure environment variables** - Set domain and email
3. **Run container** - Use `/StartStopScripts/Website/start.bat`
4. **Certificate generation** - Automatic Let's Encrypt certificate on first startup
5. **Automatic renewal** - Certificates renew automatically every 90 days

### How It Works

1. **Container starts** → SSL setup runs before web application
2. **Certificate validation** → Checks for existing valid certificates (>30 days remaining)
3. **Let's Encrypt generation** → Uses HTTP challenge on port 80 for domain validation
4. **Certificate storage** → Copies certificates to `/app/ssl/` for ASP.NET usage
5. **Renewal setup** → Installs cron jobs for automatic certificate renewal
6. **Application startup** → Launches ASP.NET with HTTPS on ports 8080/8443

### Force Certificate Renewal

For certificate troubleshooting, you can force regeneration:

1. Edit `/StartStopScripts/Website/start.bat`
2. Uncomment: `rem set cmd=%cmd% -e FORCE_SSL_RENEWAL=true`
3. Restart container
4. Comment the line again to return to normal behavior

### Network Configuration

**Router Port Forwarding:**
- External port 80 → Internal port 8080 (Required for Let's Encrypt validation)
- External port 443 → Internal port 8443 (HTTPS traffic)

**Prerequisites:**
- Domain must resolve to your server's public IP
- Port 80 must be accessible from internet for Let's Encrypt validation
- No other services using port 80 during certificate generation

### Certificate Storage

Certificates are stored persistently on the host at:
- **Host path**: `/StartStopScripts/Website/SelfHosting/ssl/`
- **Container path**: `/app/ssl/`
- **Files**: `fullchain.pem`, `privkey.pem`

Certificates survive container recreation and are automatically reused if valid.

For more technical details and architecture information, see [CLAUDE.md](CLAUDE.md).