# Session Memory - June 17, 2025 - IAC Deployment Troubleshooting

## Context
This session focused on troubleshooting and fixing OpenClone IAC deployment issues, specifically around Kubernetes cluster creation, storage provisioning, and load balancer timing problems.

## Key Accomplishments

### 1. Cluster Creation CPU/GPU Choice Enhancement
**Modified**: `/IAC/scripts/cluster_create_and_destroy/vultr/cluster.sh`
- **Added interactive prompt** for CPU vs GPU cluster selection
- **Implementation**: Loop-based validation ensuring user enters 1 or 2
- **Options**: 
  - 1) CPU cluster (cheapest CPU nodes) - `get_cheapest_cpu_node_plan()`
  - 2) GPU cluster (cheapest GPU nodes) - `get_cheapest_gpu_node_plan()`
- **User Experience**: No defaults, graceful retry until valid choice

### 2. SSL/TLS Timeout Extensions  
**Modified**: `/IAC/terraform/ssl.tf`
- **Extended kubectl wait timeouts** from 300s (5 minutes) to 1800s (30 minutes)
- **Updated timeout locations**:
  - nginx-ingress controller readiness wait
  - cert-manager pods readiness wait  
  - cert-manager CRDs establishment wait
- **Rationale**: Vultr load balancer provisioning can take 5-15 minutes

### 3. tmux Mouse Support Enhancement
**Modified**: `/IAC/.devcontainer/devcontainer.json`
- **Enhanced "Claude TMUX" VS Code button** to automatically enable mouse support
- **Command updated**: Added `tmux set -g mouse on` to the session creation sequence
- **Benefits**: 
  - Mouse scrolling for long deployment logs
  - Text selection with mouse clicks
  - Pane resizing via mouse drag

### 4. Critical Load Balancer Timing Fix
**Problem**: nginx ingress controller load balancer IP not available when DNS records need to be created

**Root Cause Analysis**:
- Regular Kubernetes LoadBalancer services get IPs quickly from Vultr
- nginx ingress controller is more complex - reverse proxy requiring pod readiness before IP appears in service status
- Terraform tried to access `data.kubernetes_service.nginx_ingress_controller[0].status[0].load_balancer[0].ingress[0].ip` before array was populated

**Solution 1 - Defensive Programming** (initial approach):
```hcl
# Used try() function for graceful failure
data = try(data.kubernetes_service.nginx_ingress_controller[0].status[0].load_balancer[0].ingress[0].ip, null)
count = ... && try(..., null) != null ? 1 : 0
```

**Solution 2 - Automated Retry Logic** (final implementation):
**Added**: `/IAC/terraform/ssl.tf` - `null_resource.wait_for_nginx_ingress_ip`
- **30-minute timeout** with 30-second polling intervals
- **Active kubectl monitoring** of ingress controller service status
- **Progress feedback** showing elapsed time vs total timeout
- **Automated completion** - no manual intervention required

**Modified**: `/IAC/terraform/public-ip.tf`
- **Updated dependency**: `depends_on = [null_resource.wait_for_nginx_ingress_ip]`
- **Removed try() logic** - now safe to access IP directly after wait completes

## Technical Deep Dive

### Storage System Race Condition Resolution
**Issue**: Longhorn storage provisioner not ready when PVCs created, causing pods to remain in Pending state
**Solution**: 
- **Fresh container restarts** cleared state locks
- **Extended wait periods** allowed Longhorn to fully initialize
- **CPU cluster selection** simplified resource constraints

### Deployment Architecture Understanding  
**Command**: `/scripts/cluster_create_and_destroy/create.sh --create`
**Sequence**:
1. Environment setup and Terraform workspace creation
2. Cluster creation (if needed) with user choice CPU/GPU
3. Terraform initialization
4. Longhorn storage installation
5. Application deployment via Terraform with dynamic image resolution

### Load Balancer Provisioning Timing
**nginx ingress vs Regular Services**:
- **Regular LoadBalancer services**: Simple IP assignment from cloud provider
- **nginx ingress controller**: Complex initialization requiring:
  1. LoadBalancer service creation ✅
  2. Vultr external IP provisioning ✅  
  3. nginx controller pod startup ✅
  4. nginx controller registration with LoadBalancer ❌ (where failures occurred)
  5. IP appearance in service status ❌ (required for DNS records)

### Deployment Success Patterns
**Successful CPU Cluster Deployment**:
- ✅ All application deployments completed (database, u-2-net, website)
- ✅ Main application load balancer provisioned  
- ✅ Storage system working (no PVC binding issues)
- ❌ Only DNS record creation failed due to nginx ingress timing

## Documentation Updates

### Updated IAC CLAUDE.md
**Added Deployment Duration Section**:
- Expected time: Up to 1 hour for full cluster setup
- Progress indicators: "Still creating..." vs immediate failures
- Deployment command documentation and workflow explanation

### Session Insights
**Key Learning**: The "retry the same deployment" strategy proved highly effective:
- **First run**: Identifies timing-dependent failures
- **Second run**: Often succeeds as infrastructure stabilizes  
- **Validation**: Confirms root cause is timing rather than configuration

## File Changes Summary
1. `/IAC/scripts/cluster_create_and_destroy/vultr/cluster.sh` - CPU/GPU choice prompt
2. `/IAC/terraform/ssl.tf` - 30-minute timeouts + automated IP wait logic  
3. `/IAC/.devcontainer/devcontainer.json` - tmux mouse support
4. `/IAC/terraform/public-ip.tf` - Updated dependencies for nginx ingress IP
5. `/IAC/CLAUDE.md` - Deployment duration and process documentation

## Future Considerations
- Monitor new timeout values for effectiveness in production
- Consider similar automated retry patterns for other cloud provider timing issues
- Evaluate if CPU clusters provide sufficient performance for production workloads
- Test automated deployment flow end-to-end without manual intervention

## Troubleshooting Patterns Established
1. **Storage issues**: Check PVC binding and Longhorn readiness
2. **Load balancer timing**: Allow extended time for cloud provider provisioning  
3. **State lock issues**: Fresh container restart clears locks
4. **nginx ingress delays**: Now handled automatically with retry logic
5. **Deployment validation**: "Still creating..." indicates healthy progress vs immediate failures