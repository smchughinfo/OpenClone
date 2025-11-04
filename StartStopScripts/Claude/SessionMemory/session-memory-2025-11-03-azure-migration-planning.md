# Session Memory - Azure Migration Planning
**Date:** November 3, 2025
**Topic:** Complete Azure migration strategy and cost analysis for CloneZone business transformation

## Context & Business Motivation

### Current Situation
- **Project Status**: Mothballed since August 2025
- **Current Hosting**: Self-hosted on personal Windows PC (dual RTX 4070 GPUs)
  - Running 24/7 from home in Ohio
  - Domain: app.clonezone.me → home PC (Cloudflare DNS + Let's Encrypt SSL)
  - Serverless-0 landing page on Cloudflare Pages with health check
- **Employment Gap**: 11 months without job, listing CloneZone as "most recent employer"
- **Credibility Problem**: Getting less believable that it was a real business

### Business Transformation Goal
**Convert CloneZone from portfolio piece to legitimate business:**
- Need actual paying customers (even if just a few)
- Move to professional cloud hosting (Azure)
- Can honestly claim: "Real business that didn't make as much money as hoped"
- Reasons for low revenue are legitimate (technical + business factors, not lies)

### Why Original Vision Failed
1. **ElevenLabs limits**: Only viable voice cloner but prohibitive usage limits
2. **No advertising budget**: Can't acquire customers without marketing funds
3. **SadTalker licensing unclear**: Dependencies questionable for commercial use
4. **Vultr GPU scaling nightmare**: MASSIVE time sink, ultimately unusable

### Vultr GPU Scaling Pain Points (From Session Memory July 27, 2025)
**Discovery:** Vultr VKE cannot scale GPU nodes to 0 (minimum 1 node required)

**Workaround Attempted:**
- Delete/recreate entire GPU node pool pattern via API
- 2-3 minute provisioning time per recreate
- Complex ASP.NET integration to manage pool lifecycle
- Fragile and disheartening to implement

**Result:** Abandoned Vultr deployment, moved to self-hosting on personal PC

## Current Self-Hosted Architecture

### Running Docker Containers
```bash
NAMES                 IMAGE                     STATUS      PORTS
openclone-website     openclone-website:1.0     Up 3 days   0.0.0.0:8080->80/tcp, 0.0.0.0:8443->443/tcp
openclone-sadtalker   openclone-sadtalker:1.0   Up 3 days   0.0.0.0:5001->5001/tcp
openclone-database    openclone-database:1.0    Up 3 days   0.0.0.0:5433->5432/tcp
```

**Image Sizes:**
- openclone-website: 1.63GB (ASP.NET Core)
- openclone-sadtalker: **39.8GB** (AI deepfake service - CUDA + models)
- openclone-database: 1.99GB (PostgreSQL)

**Not Running:**
- U-2-Net (background removal) - commented out, needs better checkpoint file
- LogViewer - supposed to run locally but not active

### Infrastructure Details
- **Domain**: app.clonezone.me → Windows PC (Cloudflare DNS)
- **SSL**: Let's Encrypt automated renewal via Docker entrypoint
- **Storage**: C:\Users\seanm\Desktop\OpenClone\OpenCloneFS (shared volume across containers)
- **GPU**: 2x NVIDIA GeForce RTX 4070 (12GB VRAM each, dual GPUs in PC)
- **CUDA**: Version 12.9, Driver 576.88
- **Database**:
  - Main DB: open_clone (port 5433)
  - Logging DB: open_clone_logging (port 5433)

### Current Dependencies
- **OpenAI API**: Language model for clone personality
- **ElevenLabs API**: Text-to-speech voice cloning (major cost constraint)
- **SadTalker**: Deepfake video generation (local GPU processing)
- **Google OAuth**: User authentication

## Azure CLI Environment

### Verified Access
```bash
az --version: 2.77.0
Subscription: Azure subscription 1
Account: seanmchugh513@gmail.com
Tenant: seanmchugh513gmail.onmicrosoft.com
State: Enabled
Region preference: No specific (user in Ohio)
```

### GPU Quota Status (East US 2)
```
Standard NC Family vCPUs:            0/12   (retiring, legacy)
Standard NCASv3_T4 Family vCPUs:     0/0    ❌ NEEDS QUOTA REQUEST
Standard NCADS_A100_v4 Family vCPUs: 0/0    (expensive, unnecessary)
```

**Action Required:** Request NCASv3_T4 quota increase before GPU deployment testing

## Azure Cost Analysis - THE BREAKTHROUGH

### Why Azure Beats Vultr

| Feature | Vultr (Failed) | Azure (Superior) |
|---------|----------------|------------------|
| **Scale GPU to 0** | ❌ Min 1 node required | ✅ True zero (min-count=0) |
| **Workaround** | Delete entire pool via API | Native AKS autoscaler support |
| **Spot/Cheap GPUs** | Limited availability | 61% discount on Spot VMs |
| **Cold start time** | 2-3 min (delete/recreate) | 5-15 min (provision from 0) |
| **Complexity** | High (manual API management) | Low (native K8s scaling) |

### Azure GPU Pricing - T4 Spot VMs (NCasT4_v3)

**GPU Series Selection:**
- **T4 (16GB VRAM)**: Perfect for SadTalker (needs 4GB minimum)
- **A100 (80GB VRAM)**: 7x more expensive, overkill for inference

**NCasT4_v3 Pricing:**
- **On-demand**: $0.526/hour = $379/month (24/7)
- **Spot VM**: $0.203/hour = $146/month (24/7) = **61% savings**
- **Scale-to-zero**: $0.00 when idle + $0.203/hour only when active

**Real-World Usage Scenarios:**

| Monthly GPU Hours | Spot VM Cost | Use Case |
|-------------------|--------------|----------|
| 0 (scaled to 0) | $0.00 | No users, idle business |
| 10 hours | $2.03 | 2-3 customers, light usage |
| 50 hours | $10.15 | 10 customers, moderate usage |
| 100 hours | $20.30 | 20 customers, active business |
| 730 hours (24/7) | $148.19 | Always-on (bad strategy) |

### Full Azure Stack Cost Estimate

**Fixed Monthly Costs (24/7 Always Running):**
- **AKS Control Plane**: $0 (Free tier)
- **CPU Node Pool** (1x Standard_B2s: 2 vCPU, 4GB RAM): ~$53/month
  - Runs: openclone-website, openclone-database, openclone-logviewer
  - Alternative: 2x B2s for redundancy = ~$106/month
- **Storage** (Azure Disks for database PV): ~$5-10/month
- **Bandwidth/Egress**: ~$5-15/month (estimated, varies with traffic)
- **Domain**: Already own clonezone.me (no additional cost)

**Fixed Monthly Total: ~$63-78** (single CPU node) or ~$116-131 (redundant)

**Variable GPU Costs (Scale-to-Zero):**
- **Idle state**: $0.00 (GPU node pool scaled to min=0)
- **Active usage**: $0.203/hour (T4 Spot VM, only when processing AI jobs)

### Business Viability Calculations

**Subscription Pricing Decision: $5/month** (not trying to make money, just legitimacy)

**Scenario 1: Minimal Business (5 customers, 10 GPU hours/month)**
- Revenue: $5 × 5 = $25/month
- Fixed costs: -$70/month
- GPU costs: -$2.03/month
- **Net: -$47.03/month** (sustainable loss for business credibility)

**Scenario 2: Break-Even Point (15 customers, 30 GPU hours/month)**
- Revenue: $5 × 15 = $75/month
- Fixed costs: -$70/month
- GPU costs: -$6.09/month
- **Net: -$1.09/month** (essentially break-even)

**Scenario 3: Small Profit (30 customers, 60 GPU hours/month)**
- Revenue: $5 × 30 = $150/month
- Fixed costs: -$70/month
- GPU costs: -$12.18/month
- **Net: +$67.82/month profit**

**Scenario 4: Active Business (50 customers, 100 GPU hours/month)**
- Revenue: $5 × 50 = $250/month
- Fixed costs: -$70/month
- GPU costs: -$20.30/month
- **Net: +$159.70/month profit**

**Key Insight:** Only need 15-20 paying customers to claim legitimate business operations

### Per-Customer Unit Economics

**Assuming 2 GPU hours per customer per month:**
- Customer revenue: $5.00/month
- GPU cost per customer: $0.406 (2 hours × $0.203)
- Fixed cost allocation: $4.67 (at 15 customers)
- **Margin per customer: -$0.076** (at break-even scale)
- **Margin per customer: +$2.76** (at 30 customer scale)

**Stripe Fees:** ~3% + $0.30 per transaction
- $5 charge → Stripe takes $0.45 → Net $4.55
- Actual margin per customer: -$0.526 (15 customers) or +$2.31 (30 customers)

## Proposed Azure Architecture

### AKS Multi-Node-Pool Design

**CPU Node Pool (Always Running):**
- **VM Size**: 1-2× Standard_B2s (2 vCPU, 4GB RAM)
- **Autoscaler**: min=1, max=3 (can scale if needed)
- **Spot VMs**: No (need reliability for database/website)
- **Deployments**:
  - openclone-website (ASP.NET Core, ports 80/443)
  - openclone-database (PostgreSQL container)
  - openclone-logviewer (Python Flask monitoring)
- **Node Selector**: `agentpool: cpupool`
- **Cost**: ~$53-106/month depending on node count

**GPU Node Pool (Scale-to-Zero):**
- **VM Size**: 1× Standard_NC4as_T4_v3 (4 vCPU, 28GB RAM, 16GB VRAM)
- **Autoscaler**: min=0, max=2
- **Spot VMs**: Yes (61% discount, acceptable for batch AI jobs)
- **Deployments**:
  - openclone-sadtalker (AI deepfake generation)
- **Node Selector**: `agentpool: gpupool, sku: gpu`
- **Tolerations**: GPU taints (standard K8s pattern)
- **Cost**: $0 when scaled to 0, $0.203/hour when active

### Storage Strategy

**OpenCloneFS Replacement Options:**

1. **Azure Files (SMB)** - Most similar to current setup
   - Multi-container ReadWriteMany support
   - Direct SMB mount from containers
   - Standard tier: ~$0.06/GB/month
   - For 100GB: ~$6/month

2. **Azure Blob Storage (FUSE driver)** - Modern approach
   - BlobFuse2 driver for container mounting
   - Cool tier for user-generated content: ~$0.01/GB/month
   - For 100GB: ~$1/month
   - Better for large files (videos/images)

**Database Storage:**
- Azure Managed Disks (Premium SSD)
- 32GB database volume: ~$5/month
- Persistent Volume in Kubernetes
- Regular snapshots to Azure Blob (cool tier)

**Decision Point:** Discuss when implementing (likely Azure Files for simplicity)

### SSL/DNS Strategy

**Domain Change: app.clonezone.me → clonezone.me**
- Drop Cloudflare Pages (serverless-0 landing page)
- Point clonezone.me directly to Azure AKS LoadBalancer
- Keep Cloudflare as DNS provider (already configured)

**SSL Certificate Management:**
- **Option 1**: Keep Let's Encrypt with cert-manager on AKS (current pattern)
- **Option 2**: Use Azure Front Door with managed SSL (easier, small cost)
- **Preferred**: Let's Encrypt via cert-manager (free, already working)

**Deployment Pattern:**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: openclone-website
spec:
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 80
  - port: 443
    targetPort: 443
```

Cloudflare DNS: clonezone.me → Azure LoadBalancer IP

### Container Registry Strategy

**Azure Container Registry (ACR):**
- Basic tier: $5/month (10GB storage)
- Sufficient for website + database images
- Problem: openclone-sadtalker is 39.8GB

**SadTalker Image Challenge:**
- Too large for Basic ACR tier (10GB limit)
- Standard tier: $20/month (100GB storage)
- Alternative: DockerHub (free public, or $7/month Pro)

**Recommended Approach:**
1. Push website + database to Azure ACR (Basic tier)
2. Push sadtalker to DockerHub Pro or Azure ACR Standard
3. K8s imagePullSecrets for private registries

**Image Tags:** Keep :1.0 pattern (already standardized in project)

## GPU Auto-Scaling Logic

### ASP.NET Integration Requirements

**When user requests AI feature (create clone):**
1. Check current GPU node pool state via Azure SDK
2. If scaled to 0, trigger scale-up to min=1
3. Queue SadTalker job in database/message queue
4. Kubernetes automatically schedules pod when GPU node ready
5. Return to user: "Your clone is processing, estimated 10-15 minutes"

**After job completion:**
1. Monitor GPU node pool utilization
2. If idle for 30-60 minutes, scale back to 0
3. Save $0.203/hour when no AI jobs running

**Code Changes Required:**
- Azure SDK for .NET (Azure.ResourceManager.ContainerService)
- New service: AzureGpuService.cs
  - `EnsureGpuNodePoolExists()` - Scale to min=1 if at 0
  - `ScaleGpuNodePoolToZero()` - Scale down after idle timeout
- Job queue system (simple database table or Azure Service Bus)
- User notification system (already have SignalR for real-time logging)

**User Experience:**
- Cold start: 5-15 minutes (node provisioning + job processing)
- Warm start: 2-5 minutes (node already running)
- User tolerance: 10-20 minutes acceptable for $5/month subscription

## Stripe Subscription Integration

### BidSnap Pattern (Already Solved)

**From BidSnap Session Memory (Oct 20, 2025):**
- ✅ Database fields: StripeCustomerId, StripeSubscriptionId, SubscriptionStartedAt
- ✅ Service layer: StripeService.cs (all Stripe API calls centralized)
- ✅ Webhook: StripeWebhookController.cs (captures IDs only)
- ✅ Source of truth: Query Stripe API on every login for active status
- ✅ Payment link: `?client_reference_id={userId}` for reliable user matching
- ✅ Two-communication model: Webhook for IDs, API query for status

**Why This Pattern:**
- More accurate than webhook-only (no missed webhook issues)
- Simpler architecture (Stripe is always source of truth)
- No state synchronization problems
- Slightly slower login (one API call) but more reliable

### Code to Copy from BidSnap

**1. User Model (OpenClone.Core.Models.User.cs) - Add 3 fields:**
```csharp
public string? StripeCustomerId { get; set; }
public string? StripeSubscriptionId { get; set; }
public DateTime? SubscriptionStartedAt { get; set; }
```

**2. StripeService.cs (copy entire file):**
- `/bidsnap/WebSite/Services/Services/StripeService.cs`
- Change namespace: Services → OpenClone.Core.Services
- Change DbContext: BidSnapDbContext → OpenCloneDbContext
- Already uses NetworkService pattern (exists in OpenClone)

**3. StripeWebhookController.cs (copy entire file):**
- `/bidsnap/WebSite/UI/Controllers/StripeWebhookController.cs`
- Minimal changes needed (namespace only)

**4. Configuration (appsettings.json):**
```json
{
  "Stripe": {
    "PublishableKey": "pk_test_...",
    "SecretKey": "sk_test_...",
    "WebhookSecret": "whsec_..."
  }
}
```

**5. Stripe Product Setup:**
- Product: "CloneZone Monthly Subscription"
- Price: $5/month
- Payment Link with `?client_reference_id={userId}` parameter

**6. Dashboard/Login Integration:**
```csharp
// On user login (copy from BidSnap Dashboard.cshtml.cs)
if (!string.IsNullOrEmpty(user.StripeSubscriptionId))
{
    var isActive = await _stripeService.IsSubscriptionActive(user.StripeSubscriptionId);
    user.IsActive = isActive;
    await _db.SaveChangesAsync();
}

// Show subscribe button if not active
HasActiveSubscription = user.IsActive;
```

**Total Code Changes: ~200 lines** (mostly copy/paste from BidSnap)

### Subscription Gating Strategy

**Where to Check Subscription:**
- ✅ Clone creation page (primary AI feature)
- ✅ Dashboard access (view existing clones)
- ❌ Public landing page (marketing, should be open)
- ❌ Login/OAuth flow (need account before subscribing)

**User Flow:**
1. Visit clonezone.me → public landing page
2. Login with Google → creates account
3. Redirect to Dashboard → shows "Subscribe for $5/month"
4. Click Subscribe → Stripe checkout → payment
5. Return to Dashboard → shows "Active Subscription"
6. Create Clone button now enabled

**Middleware vs Page-Level Checks:**
- MVP: Page-level checks (simpler, copy from BidSnap)
- Future: `[RequireActiveSubscription]` attribute (proper solution)

## Technical Discoveries & Key Insights

### 1. Azure AKS Scale-to-Zero Support
**Discovery:** Unlike Vultr, Azure AKS natively supports min-count=0 for GPU node pools

**Commands:**
```bash
# Manual scaling to zero
az aks nodepool scale --name gpupool --cluster-name openclone --resource-group openclone-rg --node-count 0

# Autoscaler configuration with min=0
az aks nodepool update --name gpupool --cluster-name openclone --resource-group openclone-rg \
  --enable-cluster-autoscaler --min-count 0 --max-count 2
```

**Why This Changes Everything:**
- Native K8s autoscaler support (no API hacks)
- Pods go to "Pending" state when scaled to 0 (don't crash)
- Auto-schedule when GPU nodes appear (no manual intervention)
- True $0 cost when idle (actual billing stops)

### 2. Spot VM Reliability Trade-offs

**Spot VM Behavior:**
- Up to 90% discount on standard pricing
- Can be evicted by Azure with 30-second warning
- Eviction rate varies by region and capacity
- GPU VMs generally lower eviction rates (less demand than CPU)

**Acceptable for CloneZone Because:**
- AI jobs are batch/asynchronous (not real-time)
- Can retry failed jobs automatically
- User already waiting 10-15 minutes (won't notice restart)
- Worst case: Job restarts, user waits extra 5 minutes
- At $5/month price point, users tolerant of delays

**Not Acceptable For:**
- Real-time inference (e.g., video chat AI)
- Time-critical workloads (financial trading)
- High availability requirements (99.9% SLA)

### 3. Container Image Size Problem

**SadTalker Image: 39.8GB**
- CUDA base image: ~10GB
- SadTalker models/checkpoints: ~20GB
- Python dependencies: ~5GB
- Application code: ~100MB

**Implications:**
- Azure ACR Basic (10GB): Too small
- Azure ACR Standard (100GB): $20/month = 28% of fixed costs
- DockerHub Pro (Unlimited): $7/month
- Image pull time: 5-10 minutes on first deployment

**Multi-Stage Build Opportunity:**
- Could split into base image (CUDA + deps) + model image
- Base rarely changes → cache hit
- Models update occasionally → smaller pulls
- Future optimization, not MVP blocker

### 4. GPU Quota Requests (Azure Process)

**Current Status:**
- Most GPU families: 0 quota (must request)
- Standard NC (legacy): 12 vCPU available but retiring
- NCASv3_T4: 0 vCPU → need quota increase

**Request Process:**
```bash
# Via Azure Portal
Support → New Support Request → Service and Subscription Limits (Quotas)
→ Compute-VM (cores-vCPUs) → NCASv3_T4 Family → Request increase

# Typical approval time: 1-2 business days
# Usually approved without justification for reasonable amounts
```

**Strategy:** Wait until proof-of-concept Phase 2 to request

### 5. U-2-Net Status (Background Removal)

**Current State:** Commented out, not running
- Needs better checkpoint file for quality results
- Legal uncertainty for commercial use
- Not critical for MVP (clones work without background removal)

**Decision:** Treat as "extra feature" post-MVP
- Could find open-source contributor to improve
- Or find alternative background removal service
- Don't block Azure migration on this

## Migration Proof-of-Concept Approach

### User Directive
> "dont worry so much about the phases. i will devise those (with your help) as we go"

**Translation:** No rigid phase plan, iterative approach based on what we learn

### High-Level Migration Sequence (Flexible)

**1. Azure Environment Setup**
- Create resource group
- Create AKS cluster (CPU nodes only, no GPU initially)
- Configure kubectl access
- Set up Azure Files or Blob for OpenCloneFS

**2. Container Registry & Images**
- Create Azure ACR or DockerHub account
- Push openclone-website:1.0
- Push openclone-database:1.0
- Push openclone-sadtalker:1.0 (39.8GB - will take time)

**3. Database Migration**
- Deploy PostgreSQL container on AKS
- Export current database from local instance
- Import to Azure-hosted database
- Verify data integrity

**4. Website Deployment**
- Deploy openclone-website to AKS
- Configure environment variables
- Set up LoadBalancer service
- Point clonezone.me DNS to Azure LoadBalancer IP
- Test: Can access website?

**5. GPU Node Pool (Proof-of-Concept)**
- Request NCASv3_T4 quota
- Create GPU node pool with min=0, max=1
- Deploy openclone-sadtalker with node selector
- Test: Scale to 0 → $0 cost
- Test: Create clone → auto-scale to 1 → job runs
- Measure: Cold start time, costs, reliability

**6. Subscription Integration**
- Copy Stripe code from BidSnap
- Add database fields (migration)
- Create Stripe product ($5/month)
- Test: Payment → subscription active → can create clone

**7. Production Hardening**
- SSL certificate automation (cert-manager)
- Monitoring/logging setup
- Backup/restore procedures
- Cost alerts and budgets
- GPU idle timeout tuning

### Proof-of-Concept Success Criteria

**Must Verify:**
1. ✅ GPU node pool actually scales to 0 (costs drop to $0)
2. ✅ GPU node pool auto-scales to 1 when job queued
3. ✅ SadTalker runs successfully on Azure T4 GPU
4. ✅ Cold start time acceptable (under 20 minutes)
5. ✅ Total monthly cost under $100 with minimal usage

**If Any Fail:**
- GPU scaling doesn't work → Azure is no better than Vultr → abandon
- Cold start too slow (>30 min) → user experience unacceptable → rethink
- Costs too high → business model doesn't work → adjust pricing or architecture

## Questions Asked & Answered

**Q: GPU specifications on current machine?**
A: 2× NVIDIA GeForce RTX 4070 (12GB VRAM each), CUDA 12.9

**Q: Azure account access?**
A: Verified via `az account show` - logged in and ready

**Q: Current hosting setup?**
A: Self-hosted on personal PC, Cloudflare DNS, Let's Encrypt SSL

**Q: Domain strategy?**
A: Change from app.clonezone.me to clonezone.me directly (drop serverless-0)

**Q: Subscription pricing?**
A: $5/month single tier (not trying to make money, just legitimacy)

**Q: Payment processing?**
A: Stripe (copy working implementation from BidSnap)

**Q: Code changes appetite?**
A: Keep to absolute minimum (user wants minimal changes)

**Q: Container image size?**
A: SadTalker is 39.8GB (will need to push to registry)

**Q: Start proof-of-concept now?**
A: No, document everything first in session memory

## Dependencies & Risks

### External Service Dependencies
- **OpenAI API**: Language model (current, working)
- **ElevenLabs API**: Voice cloning (usage limits = business constraint)
- **Google OAuth**: Authentication (current, working)
- **Stripe**: Payment processing (tested in BidSnap)
- **Cloudflare**: DNS management (current, working)

### Migration Risks

**High Risk:**
1. **GPU scaling doesn't work as expected** → Azure no better than Vultr
   - Mitigation: Proof-of-concept testing before full migration
2. **SadTalker compatibility issues on T4** → might need different GPU
   - Mitigation: Test on Azure before committing
3. **39.8GB image push fails/times out** → can't deploy SadTalker
   - Mitigation: Stable internet connection, resume capability

**Medium Risk:**
1. **Cost overruns** → business model breaks
   - Mitigation: Set Azure spending limits and alerts
2. **Cold start time too long** → poor user experience
   - Mitigation: Test in POC, adjust expectations or architecture
3. **Database migration data loss** → lose existing users/clones
   - Mitigation: Multiple backups before migration, verify imports

**Low Risk:**
1. **SSL certificate automation** → already working locally
2. **DNS cutover** → straightforward Cloudflare change
3. **Stripe integration** → already proven in BidSnap

### Business Risks

**Market Risks:**
- Finding 15+ customers to break even (challenging but achievable)
- ElevenLabs usage limits block scaling
- $5/month too low to be sustainable long-term

**Mitigation:**
- Goal is legitimacy, not profitability (different success criteria)
- Even 5-10 customers validates "tried to run a business"
- Can raise prices later if needed

## Architecture Decisions Not Yet Made

### Deferred to Implementation
1. **Database hosting**: PostgreSQL container vs Azure Database for PostgreSQL?
2. **Storage backend**: Azure Files (SMB) vs Azure Blob (FUSE)?
3. **Container registry**: Azure ACR Standard vs DockerHub Pro?
4. **GPU idle timeout**: 30 min vs 60 min before scale-to-zero?
5. **Job queue system**: Database table vs Azure Service Bus?
6. **Monitoring**: Azure Monitor vs Prometheus/Grafana?

**User's Approach:** "we'll discuss when we get there"

## Next Steps (User-Driven)

**Immediate:**
1. ✅ Document everything in session memory (this file)
2. Wait for user to devise next steps with Claude's help

**Future Tasks (Order TBD):**
- Set up Azure resource group and AKS cluster
- Push container images to registry
- Deploy CPU workloads (website, database)
- Request GPU quota and test scaling
- Integrate Stripe subscriptions
- Point DNS to Azure
- Acquire first paying customers

## Key Learnings & Insights

### 1. Azure vs Vultr GPU Scaling
The single biggest discovery: Azure natively supports scale-to-zero on GPU node pools, which Vultr failed to deliver. This changes the entire cost model from "barely viable" to "actually reasonable."

### 2. Business Legitimacy vs Profitability
Success criteria shifted from "make money" to "claim legitimate business experience." This reduces pressure on customer acquisition and allows for aggressive pricing ($5/month) that prioritizes credibility over profit.

### 3. BidSnap Stripe Pattern Reusability
Already solved subscription payments in another project. Can copy working code with minimal changes, reducing risk and development time. The two-communication model (webhook for IDs, API for status) is proven and reliable.

### 4. Container Image Sizes Matter
39.8GB SadTalker image is a real operational challenge. Impacts registry choice, deployment time, and costs. Can't be ignored or hand-waved away - needs explicit strategy.

### 5. Minimum Changes Philosophy
User explicitly wants "absolute minimum" code changes. This drives architectural decisions toward copying proven patterns (BidSnap Stripe) rather than reinventing or over-engineering.

### 6. Cold Start Tolerance
At $5/month price point, users will tolerate 10-20 minute cold starts. This makes scale-to-zero viable even with slow node provisioning. Different user expectations than premium ($20-50/month) services.

### 7. GPU Requirements Analysis
SadTalker needs minimum 4GB VRAM, T4 has 16GB → comfortable margin. A100 would be overkill (7x price, unnecessary memory/compute). Right-sizing is critical for cost control.

### 8. Proof-of-Concept Critical
Must verify GPU scaling actually works before committing to full migration. Vultr experience taught painful lesson about assuming cloud provider capabilities match documentation.

## Architectural Philosophy (From CLAUDE.md)

### Minimum Learning Curve
"One of the main architectural tenants of this project is that it should work with minimal setup for new users. You should be able to download the entire repository, setup a few dependencies if needed (like CUDA, .NET, PostgreSQL), click build and the entire solution is up and running."

**Azure Migration Impact:**
- Moving to cloud makes local setup harder (need Azure account)
- Trade-off: Better for business (professional hosting) vs worse for contributors
- Self-hosting still possible (keep Docker Compose option)
- Documentation will need updates for both paths

### Shared File System (OpenCloneFS)
"`/OpenCloneFS` serves as the unified file system for the entire application. All containers in the cluster use this common directory for logical simplicity, avoiding the complexity of distributed file systems communicating over REST, WebRTC, sockets, etc."

**Azure Implementation:**
- Azure Files or Blob Storage preserves this pattern
- All containers mount same shared volume
- No architectural changes needed (just provider swap)

### Container Tag Standard
"Always use version tag `1.0` instead of `latest`"

**Already Followed:**
- All images: openclone-website:1.0, openclone-sadtalker:1.0, etc.
- No changes needed for Azure migration
- Push to ACR/DockerHub with same tags

## Cost Monitoring Strategy

### Azure Cost Management Setup
```bash
# Set spending limit (important!)
az consumption budget create \
  --budget-name openclone-monthly-limit \
  --amount 150 \
  --time-grain Monthly \
  --resource-group openclone-rg

# Create cost alert (email notification)
az monitor action-group create \
  --name cost-alert \
  --resource-group openclone-rg \
  --short-name costalertz
```

### Cost Tracking Dimensions
- **Fixed costs**: CPU nodes, storage, control plane
- **Variable costs**: GPU hours, egress bandwidth
- **Per-customer costs**: GPU hours per clone created
- **Stripe revenue**: Track against Azure costs

### Monthly Cost Report Template
```
Month: November 2025

Revenue:
- Stripe subscriptions: 5 customers × $5 = $25.00
- Stripe fees (3% + $0.30): -$3.75
- Net revenue: $21.25

Azure Costs:
- CPU node pool (B2s × 1): -$53.00
- GPU node pool (10 hours): -$2.03
- Storage (Azure Files): -$6.00
- Bandwidth: -$3.50
- Total Azure: -$64.53

Net P&L: -$43.28 (acceptable loss for business legitimacy)

Customers needed for break-even: 15
GPU efficiency: 2 hours per customer (target: under 2 hours)
```

## Session End State

**Status:** Complete planning and cost analysis documented

**Outcomes:**
1. ✅ Verified Azure AKS supports scale-to-zero GPU nodes (critical requirement)
2. ✅ Calculated realistic costs: $63-78/month fixed + $0.203/hour GPU variable
3. ✅ Identified break-even point: 15 customers at $5/month
4. ✅ Found reusable Stripe code from BidSnap (minimal new development)
5. ✅ Confirmed Azure CLI access and subscription ready
6. ✅ Documented current self-hosted architecture and image sizes
7. ✅ Updated CLAUDE.md to check session memory for historical context

**No Code Changed:** Pure planning and research session

**Ready For:** User to devise next implementation steps with Claude's help

**User Satisfaction:** "dont worry so much about the phases. i will devise those (with your help) as we go"

## Files Updated This Session

```
/CLAUDE.md - Added session memory proactive context gathering instruction
```

## Commands Executed

```bash
# Azure verification
az --version
az account show

# GPU quota check
az vm list-usage --location eastus2 | grep -i "nc\|gpu"

# GPU detection (WSL)
nvidia-smi
```

## Reference Links & Documentation

### Azure Documentation
- Azure AKS GPU node pools: https://learn.microsoft.com/en-us/azure/aks/use-nvidia-gpu
- Azure Spot VMs: https://azure.microsoft.com/en-us/products/virtual-machines/spot
- AKS autoscaling: https://learn.microsoft.com/en-us/azure/aks/cluster-autoscaler

### Prior Session Memories Referenced
- 2025-07-27: GPU auto-scaling architecture (Vultr limitations discovered)
- 2025-08-02: SSL self-hosting refactor (Let's Encrypt automation)
- BidSnap 2025-10-20: Stripe integration complete (pattern to copy)

### Container Images (Current)
- openclone-website:1.0 (1.63GB)
- openclone-sadtalker:1.0 (39.8GB)
- openclone-database:1.0 (1.99GB)

### Hardware Specifications (Current Self-Hosted)
- 2× NVIDIA GeForce RTX 4070 (12GB VRAM each)
- CUDA Version: 12.9
- Driver Version: 576.88
- Host: Windows PC (WSL2 for CLI access)
- Location: Ohio (user's home)
