# Server-0 - "CloneZone" Landing Page & Cluster Vending Machine

## Overview
Server-0 is the always-running entry point for OpenClone, serving as a cost-efficient "cluster vending machine" that only provisions expensive GPU resources after user authentication and payment verification. It runs as a cheap VPS hosting a simple Node.js application called "CloneZone."

## Architecture Purpose

### Two-Tier Cost Optimization
**The Problem**: GPU clusters are expensive to run 24/7, but users need accessible entry points to AI applications.

**The Solution**: Two-tier architecture with minimal upfront costs:

**Server-0 (Always Running - Cheap)**:
- Lightweight Node.js landing page
- Google OAuth authentication
- Stripe payment processing  
- Always online to catch users
- Minimal hosting costs

**Server-0-Delta (Created On-Demand - Expensive)**:
- Only created after payment verification
- Provisions actual GPU Kubernetes cluster
- Temporary instance - destroyed when session ends
- Significant compute resources for cluster creation

### Cost Benefits
- GPU resources only consumed during active user sessions
- Server-0 stays cheap and always available as the "front door"
- Server-0-Delta and GPU clusters are temporary
- Massive cost savings vs. 24/7 GPU cluster operation

## User Flow
1. User visits site → Server-0 serves CloneZone landing page
2. User authenticates with Google OAuth → Server-0 validates
3. User completes Stripe payment → Server-0 processes payment
4. Server-0 creates Server-0-Delta instance via VPS snapshot
5. Server-0-Delta provisions GPU Kubernetes cluster
6. User gets access to OpenClone AI applications
7. After session timeout, both Server-0-Delta and GPU cluster are destroyed

## Technical Architecture

### Node.js Application Stack
- **Framework**: Express.js with middleware architecture
- **Authentication**: Passport.js with Google OAuth 2.0
- **Payments**: Stripe integration for session-based billing
- **Security**: Helmet.js for security headers, CORS configuration
- **Logging**: Morgan HTTP request logging
- **Session Management**: Express-session for user state

### Application Structure
```
Server-0/
├── index.js                  # Main application entry point
├── package.json             # Dependencies (Express, Passport, Stripe)
├── config/
│   └── auth.js             # Passport Google OAuth configuration
├── middleware/
│   └── index.js            # Express middleware setup
├── routes/
│   ├── auth.js             # Authentication endpoints
│   ├── cluster.js          # Cluster management endpoints
│   ├── home.js             # Landing page routes
│   ├── api.js              # API endpoints
│   └── webhooks.js         # Stripe webhook handlers
└── public/
    ├── index.html          # CloneZone landing page
    ├── styles.css          # Landing page styling
    └── scripts.js          # Client-side JavaScript
```

## Key Features

### Authentication Flow
**Google OAuth Integration**:
- Users sign in with Google accounts
- Passport.js handles OAuth flow
- Session management for authenticated state
- Secure authentication before cluster access

### Payment Processing
**Stripe Integration**:
- Session-based payment model
- Payment verification before cluster provisioning
- Webhook handlers for payment events
- Prevents unauthorized cluster creation

### Cluster Management
**On-Demand Provisioning**:
```javascript
POST /cluster/start-cluster
// Initiates Server-0-Delta creation and cluster provisioning
// Returns immediately while process runs in background
// Logs all operations to start-cluster.log
```

**Background Processing**:
- Fire-and-forget cluster creation
- Comprehensive logging of provisioning process
- Timestamped operation tracking
- Error handling and recovery


## CICD Container Reuse Strategy

### Shared Infrastructure Logic
Server-0 leverages the CICD container for cluster provisioning:

1. **Local Development**: CICD container used as dev environment
2. **Server-0**: Runs CICD container to create Server-0-Delta instances  
3. **Server-0-Delta**: Runs CICD container to provision Kubernetes cluster

**Benefits**:
- Centralized infrastructure logic, variables, and scripts
- Consistent tooling across all deployment contexts
- Reduces code duplication and maintenance overhead
- Server-0 can easily create Server-0-Delta because it has all provisioning logic

## Environment Integration

### Required Environment Variables
```bash
# Authentication
GOOGLE_CLIENT_ID=<google_oauth_client_id>
GOOGLE_CLIENT_SECRET=<google_oauth_client_secret>

# Payments
STRIPE_SECRET_KEY=<stripe_secret_key>
STRIPE_PUBLISHABLE_KEY=<stripe_publishable_key>


# Application
PORT=3000
SESSION_SECRET=<session_encryption_secret>
NODE_ENV=production
```

### Session Management
- **Authentication State**: Persistent across browser sessions
- **Payment Verification**: Required before cluster access
- **Session Security**: Encrypted session cookies
- **Timeout Handling**: Automatic session cleanup

## Deployment Model

### Always-On Hosting
- **VPS Requirements**: Minimal (1-2 CPU cores, 1-2GB RAM)
- **Operating System**: Linux-based for cost efficiency
- **Network**: Standard web hosting (no GPU requirements)
- **Uptime**: 24/7 availability essential for user acquisition

### Scaling Considerations
- **Horizontal Scaling**: Load balancer + multiple Server-0 instances
- **Database**: Currently session-based, could add persistent user data
- **CDN**: Static assets could be CDN-distributed
- **Monitoring**: Health checks and uptime monitoring

## Integration Points

### Server-0-Delta Creation
- **Trigger**: POST /cluster/start-cluster after payment verification
- **Mechanism**: VPS snapshot deployment via hosting provider API
- **Provisioning Script**: Leverages CICD container and scripts
- **Lifecycle**: Temporary instance destroyed after session timeout

### OpenClone Cluster
- **Access Method**: Direct cluster access after provisioning
- **Resource Management**: GPU nodes provisioned on-demand
- **Application Deployment**: Full OpenClone stack (Website, SadTalker, U-2-Net, Database, LogViewer)
- **Session Duration**: Configurable timeout with cost controls

## Development Features
- **Hot Reload**: Nodemon for development
- **Debug Mode**: Comprehensive console logging
- **Error Handling**: Graceful error responses and logging
- **Security**: Helmet.js security headers, input validation

## Cost Optimization Impact
- **Server-0 Costs**: ~$5-20/month for basic VPS
- **Traditional Approach**: ~$500-2000/month for 24/7 GPU cluster
- **On-Demand Approach**: GPU costs only during active sessions
- **Break-Even Point**: Profitable with even minimal usage

This architecture treats Server-0 as an efficient "front door" that only opens expensive GPU resources when users are willing to pay for them, dramatically reducing infrastructure costs while maintaining accessibility.

**Infrastructure Context**: See `/CICD/CLAUDE.md` for deployment orchestration, multi-environment support, and infrastructure architecture rationale.