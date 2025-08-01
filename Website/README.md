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

## HTTPS Self-Hosting

The website includes built-in HTTPS support with automatic SSL certificate management for self-hosting scenarios where you want to expose OpenClone to the internet with proper SSL encryption.

### Features
- **Automatic SSL certificates** using Let's Encrypt or self-signed fallback
- **Certificate renewal** with automated cron jobs
- **Smart certificate validation** and regeneration
- **Zero-configuration setup** with sensible defaults

### Configuration

**Required Environment Variables** (for HTTPS self-hosting only):
```bash
OpenClone_Self_Hosting_Domain=your-domain.com    # Your domain name
OpenClone_Admin_Email=admin@your-domain.com      # Email for Let's Encrypt
```

### Usage

**Development/Testing (Self-Signed Certificates):**
- Default behavior - generates self-signed certificates automatically
- Browsers will show security warnings (click through to continue)
- Perfect for local testing and development

**Production (Let's Encrypt Certificates):**
- Edit `/StartStopScripts/Website/start.bat`
- Uncomment: `set cmd=%cmd% -e USE_LETSENCRYPT=true`
- Requires DNS pointing to your server before container startup
- Automatically gets trusted certificates (no browser warnings)

### How It Works

1. **Container starts** → Checks for existing SSL certificates
2. **Certificate validation** → Ensures certificates are valid and not expiring soon
3. **Automatic generation**:
   - **Let's Encrypt mode**: Gets real certificates from Let's Encrypt CA
   - **Self-signed mode**: Creates certificates with proper SAN extensions
4. **Certificate renewal** → Sets up automatic renewal cron jobs (Let's Encrypt only)
5. **Application startup** → Launches ASP.NET with HTTPS on ports 8080/8443

### Network Configuration

**Router Port Forwarding:**
- External port 80 → Internal port 8080 (HTTP redirect to HTTPS)
- External port 443 → Internal port 8443 (HTTPS)

**Access URLs:**
- `https://your-domain.com` (external visitors)
- `https://localhost:8443` (local testing)

For more technical details and architecture information, see [CLAUDE.md](CLAUDE.md).