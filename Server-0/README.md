# Server-0 - Cluster Vending Machine

![Server-0 Overview](/Documentation/server0.png)

## What is this?

This is the always-on entry point for OpenClone's cost-efficient architecture. Server-0 runs as a lightweight Node.js Express application that handles user authentication via Google OAuth, payment processing through Stripe, and on-demand provisioning of GPU clusters. It serves as a "cluster vending machine" that only creates expensive compute resources after payment verification.

The application provides a simple landing page interface and background cluster provisioning workflows. When users authenticate and pay, Server-0 creates temporary Server-0-Delta instances that provision the actual GPU Kubernetes clusters for OpenClone services.

## Setup

1. Add VS Code color theme [Doki Theme: AzurLane: Essex](https://vscodethemes.com/e/unthrottled.doki-theme/doki-theme-azurlane-essex)
2. Install VSCode extension [Remote - SSH](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh)
3. `npm install` to install dependencies
4. Set required environment variables (see list below)
5. Configure `.vscode/settings.json` for development preferences

## Environment Variables

```bash
# Authentication (Required)
GOOGLE_CLIENT_ID=<oauth_client_id>
GOOGLE_CLIENT_SECRET=<oauth_client_secret>

# Payments (Required for production)
STRIPE_SECRET_KEY=<stripe_secret_key>
STRIPE_WEBHOOK_SECRET=<webhook_signature_secret>

# Cluster Management (Required)
CLUSTER_PASSWORD=<cluster_config_access_password>

# Application (Optional)
PORT=3000
SESSION_SECRET=<session_encryption_key>
NODE_ENV=production
```

## How to run it

**Development:**
- `npm start` or `node index.js` for local development
- Server runs on port 3000 (or PORT environment variable)
- Requires Google OAuth credentials and Stripe keys for full functionality

**Production Deployment:**
- Use PM2 for process management: `pm2 start index.js --name server-0`
- Ensure all environment variables are set
- Configure reverse proxy (nginx) for SSL termination
- Set up monitoring and log aggregation

**API Endpoints:**
- `GET /` - Landing page interface
- `GET /auth/google` - Initiate OAuth flow
- `POST /cluster/start-cluster` - Background cluster provisioning
- `POST /webhooks/stripe` - Stripe payment verification

**Integration with CICD:**
- Server-0 leverages CICD container logic for Server-0-Delta provisioning
- Background scripts execute cluster creation via `./start-cluster.sh`
- All operations logged to `logs/start-cluster.log` for monitoring

For more technical details and architecture information, see [CLAUDE.md](CLAUDE.md).