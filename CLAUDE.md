# OpenClone Project

## Screenshot Handling
When the user asks to look at a screenshot or mentions screenshots:
1. Check `/mnt/c/Users/seanm/Desktop/OpenClone/StartStopScripts/Claude/Screenshots/` directory for image files
2. Read and view all screenshots in that directory
3. After viewing all screenshots, delete all files in the Screenshots directory using: `rm /mnt/c/Users/seanm/Desktop/OpenClone/StartStopScripts/Claude/Screenshots/*`

## Session Memory
**Proactive Context Gathering:**
When discussing historical aspects of the project (deployment history, architecture decisions, past issues, etc.), FIRST check session memory files in `/StartStopScripts/Claude/SessionMemory/` for relevant context before responding. Use grep to search for keywords related to the topic.

**Creating New Session Memory:**
When the user asks to "remember this conversation", "save session memory", or similar:
1. Create a comprehensive summary of key decisions, solutions, and context from the conversation
2. Save to `/StartStopScripts/Claude/SessionMemory/session-memory-YYYY-MM-DD.md`
3. Include: main topics discussed, technical solutions implemented, workflow changes, important context for future sessions
4. Reference previous session memory files when relevant to current discussions

## IAC Container Integration
Claude can execute infrastructure commands inside the IAC dev container:
- **Command Execution**: Use `/StartStopScripts/Claude/iac-exec.sh "command"` for single commands
- **Shared Terminal**: User creates IAC tmux session via VS Code button, then asks Claude to join
- **Container Tools**: kubectl (`k`), terraform, vultr-api, and deployment scripts
- **Full Documentation**: See `/Deployment/IAC/CLAUDE.md` for comprehensive integration instructions

## Shared Terminal Setup (ALWAYS DO THIS FIRST)
At the start of every session:
1. IMMEDIATELY remind the user: "If you want access to our shared terminal, please run: `/OpenClone/StartStopScripts/Claude/start.bat`" 
   (This batch file will launch Claude Code and create the tmux session, enable logging, and attach the user to it)
2. Use `tmux capture-pane -t openclone -p` to see user actions
3. Use `tmux send-keys -t openclone "command" Enter` to send commands to shared session

## Session Initialization
- Always read the main README.md file at the start of each session to understand current project status and setup instructions
- Search for and read all CLAUDE.md files in subdirectories to understand component-specific instructions and context

## Learning-Focused Workflow (Azure/Infrastructure Deployments)

**IMPORTANT**: When deploying infrastructure or performing operations where the user is learning:

1. **Explain First**: Describe what needs to be done and why before executing
2. **User Runs Commands**: Provide the command for the user to run in their terminal
3. **Wait for Feedback**: Do NOT automatically execute the next step - wait for user to report results
4. **Explain Results**: Help interpret what happened after user runs the command
5. **Confirm Understanding**: Ask if ready to proceed before moving to next step

**Why This Matters:**
- User is learning Azure Container Apps, infrastructure concepts, and deployment workflows
- Running commands themselves helps build understanding and muscle memory
- Prevents Claude from "doing everything" while user misses learning opportunities

**When to be more autonomous:**
- Routine file operations (read, grep, glob)
- Session memory documentation
- Code analysis or explanations
- Situations where user explicitly asks Claude to "just do it"

**Example of Correct Workflow:**
```
User: "Let's deploy the database"
Claude: "Great! First we need to create a Container Apps environment. This is the shared
infrastructure where all our containers run. Here's the command:

az containerapp env create --name openclone-env --resource-group openclone-rg --location westus3

This will take 3-5 minutes. Run this and let me know what happens!"

[Wait for user]

User: "It created successfully"
Claude: "Perfect! Now we can see... [explain results]. Ready for the next step?"
```

## Core Architectural Principles

### Minimum Learning Curve
One of the main architectural tenants of this project is that it should work with minimal setup for new users. You should be able to download the entire repository, setup a few dependencies if needed (like CUDA, .NET, PostgreSQL), click build and the entire solution is up and running. This principle drives design decisions throughout the project and is where the overall architecture was heading.

### Shared File System (OpenCloneFS)
`/OpenCloneFS` serves as the unified file system for the entire application. All containers in the cluster use this common directory for logical simplicity, avoiding the complexity of distributed file systems communicating over REST, WebRTC, sockets, etc. This shared file system approach makes the architecture easier to understand and reason about as a programmer.

### Self-Contained Architecture Goals
**Current Dependencies:**
- OpenAI API for language model functionality
- ElevenLabs for text-to-speech generation
- SadTalker for deepfake video generation

## Container Build Standards
**IMPORTANT**: Always use version tag `1.0` instead of `latest` when building containers:
- Build containers with: `docker build -t [container-name]:1.0 .`
- This ensures consistency with start scripts which expect `1.0` tags
- Examples: `openclone-website:1.0`, `openclone-database:1.0`, etc.

## Azure Deployment - Target State Architecture

### Architecture Overview: Azure Container Apps (Serverless)

**Decision Date:** November 3, 2025
**Rationale:** Cost optimization - reduces fixed monthly costs from ~$68 (AKS) to ~$25-35 (Container Apps)

### Component Architecture

**UPDATED:** November 4, 2025 - Combined Website + SadTalker into single Container App for simpler architecture

**1. Splash Page / Entry Point**
- **Service**: Azure Function (serverless, free tier)
- **Responsibilities**:
  - Public landing page
  - User authentication (Google OAuth)
  - Check database for subscription status
  - Spin up main Container App for paid users
- **Cost**: $0/month (free tier, minimal traffic)

**2. Database Layer (Always-On)**
- **Service**: PostgreSQL in Azure Container Apps
- **Container App**: openclone-database
- **Container**: openclone-database:1.0 (single container)
- **Scaling**: Always-on (min=1, max=1) - cannot scale to zero
- **Resources**: 0.5 vCPU, 1 GB RAM (no GPU)
- **Storage**: Azure Files persistent volume mounted at /var/lib/postgresql/data
- **Network**: Internal only (other containers access via DNS)
- **Why always-on**: Splash page needs to query for subscription status before spinning up main app
- **Cost**: ~$16-21/month (unavoidable minimum)

**3. Website + GPU Processing Layer (Scale-to-Zero Together)**
- **Service**: Azure Container Apps with Serverless GPUs
- **Container App**: openclone-app
- **Containers** (sidecar pattern - run together in same pod):
  - Container 1: openclone-website:1.0 (ASP.NET Core, handles HTTP requests)
  - Container 2: openclone-sadtalker:1.0 (GPU-enabled, processes AI jobs)
- **Communication**: Website → SadTalker via localhost (same pod)
- **Scaling**: Scale-to-zero (min=0, max=1) - both containers together
- **Resources**: 4 vCPU, 28GB RAM, T4 GPU (16GB VRAM)
- **GPU**: NVIDIA T4 via Azure Container Apps Serverless GPUs
- **Trigger**: Paid user login (Azure Function spins up the Container App)
- **Billing**: Per-second ($0.203/hour when active, $0 when scaled to zero)
- **Cold start**: 5-10 minutes (acceptable - user already logged in and waiting)
- **Cost**: $0 when idle, ~$0.20/hour when active
- **Regions**: West US 3, Australia East, Sweden Central (Serverless GPU GA as of 2025)
- **Why combined**:
  - Simpler code (no separate GPU management logic)
  - SadTalker ready immediately when user creates clone
  - Trade-off: Pay for GPU even when user just browsing (but acceptable for simplicity)

**4. Storage Layer**
- **Service**: Azure Files (SMB file share)
- **Purpose**: Replace OpenCloneFS shared filesystem
- **Mounts**:
  - Database: /var/lib/postgresql/data (persistent DB data)
  - Website: /openclonefs (shared file storage for clones/videos)
- **Cost**: ~$5-10/month

### Total Cost Estimate

**Fixed Monthly Costs:**
- Splash page (Azure Function): $0/month (free tier)
- Database: $16-21/month (always-on, cannot scale to zero)
- Storage: $5-10/month
- Bandwidth: ~$5/month
- **Total Fixed: $26-36/month**

**Variable Costs:**
- Website + GPU Container App: $0 idle, $0.203/hour when active
- Typical session: 1-2 hours (user browses + creates clones)
- 10 sessions/month (10-20 hours): $2-4
- 50 sessions/month (50-100 hours): $10-20
- 100 sessions/month (100-200 hours): $20-40

**Business Model:**
- $5/month subscription
- Break-even: 6-8 customers
- 20 customers at 5 sessions each = $100 revenue - $36 fixed - $20 GPU = $44/month profit

### Why Container Apps vs AKS

| Factor | AKS (Rejected) | Container Apps (Chosen) |
|--------|----------------|-------------------------|
| **Minimum nodes** | 1 node required | True scale-to-zero |
| **Fixed costs** | ~$68/month (B2s node) | ~$26-41/month |
| **GPU scaling** | Manual node pool management | Automatic scale 0→1→0 |
| **Complexity** | Kubernetes (kubectl, nodes, pods) | Serverless (just deploy containers) |
| **Billing** | Hourly node cost | Per-second container usage |
| **GPU support** | Yes (but complex) | Yes (serverless GPUs, GA 2025) |

### Deployment Workflow

1. **Push containers to Azure Container Registry**
   - `az acr create --name openclonecr --sku Basic`
   - Push website, database, sadtalker images

2. **Create Container Apps Environment**
   - `az containerapp env create` (shared networking/logging)

3. **Deploy Database Container**
   - Always-on (min=1)
   - Mount Azure Files for PostgreSQL data
   - Cannot scale to zero

4. **Deploy Website Container**
   - Scale-to-zero or minimal always-on
   - Connect to database
   - Handle auth, subscriptions, job triggering

5. **Deploy GPU Container**
   - Scale-to-zero (min=0, max=1)
   - T4 GPU attached
   - Triggered by website via HTTP or queue
   - Auto-scales when job arrives

### Key Differences from Self-Hosting

**No Longer Needed:**
- ❌ Kubernetes clusters, nodes, kubectl
- ❌ Docker Compose on local machine
- ❌ Let's Encrypt manual SSL management (Container Apps provides HTTPS)
- ❌ Manual node scaling scripts
- ❌ PC running 24/7

**Still Required:**
- ✅ Container images (website:1.0, database:1.0, sadtalker:1.0)
- ✅ Same code/logic (minimal changes)
- ✅ Database schema (PostgreSQL)
- ✅ OpenCloneFS concept (now Azure Files/Blob)

### GPU Quota Requirements

**Service**: Azure Container Apps Serverless GPUs
**Quota Type**: NCASv3_T4 Family vCPUs
**Minimum**: 4 vCPUs (allows 1 T4 GPU)
**Status**: Approved for Central US region (as of Nov 3, 2025)
**Regions**: Check quota in West US 3, Australia East, Sweden Central

### Migration Path from Self-Hosting

1. Keep self-hosting running (don't break production)
2. Deploy database to Container Apps (test)
3. Export data from local PostgreSQL → import to Azure
4. Deploy website to Container Apps (parallel testing)
5. Deploy GPU container (test with small jobs)
6. Verify end-to-end: login → subscribe → create clone
7. Update DNS (clonezone.me → Azure Container Apps)
8. Shut down self-hosted PC
9. Add Stripe subscriptions ($5/month)
10. Monitor costs and scale

### Code Changes Required

**Minimal changes from self-hosting:**
- Update database connection strings (Azure PostgreSQL)
- Update OpenCloneFS paths (Azure Files mount points)
- Add Azure Container Apps job trigger logic (website → GPU)
- No changes to SadTalker, database schema, or core logic

### Subscription Integration (BidSnap Pattern)

Copy working Stripe integration from BidSnap project:
- StripeService.cs (all Stripe API calls)
- StripeWebhookController.cs (webhook handler)
- User model fields (StripeCustomerId, StripeSubscriptionId, SubscriptionStartedAt)
- Two-communication model (webhook for IDs, API query for status)
- Payment link with `?client_reference_id={userId}` parameter
- ~200 lines total code changes

### Important Notes

- **Database cannot scale to zero** (must store users/subscriptions/clones)
- **$16-21/month database cost is unavoidable minimum**
- **GPU quota approved for Central US but Container Apps Serverless GPUs only in West US 3, Australia East, Sweden Central** - may need to request quota in those regions
- **39.8GB SadTalker image** - will take significant time to push to Azure Container Registry
- **Container Apps is NOT the same as Container Instances** (ACI retired July 2025)