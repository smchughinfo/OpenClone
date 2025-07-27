# Claude Instructions for IAC Project

This file contains important information for Claude when working in the IAC devcontainer.

## Kubernetes Command Usage

**IMPORTANT: Use `k` instead of `kubectl`**

Always use the `k` function instead of the standard `kubectl` command. For example:
- Use: `k get pods`
- Not: `kubectl get pods`

### Why use `k`?

The `k` function is defined in `scripts/shell-helpers/aliases.sh` and automatically added to `~/.bashrc` when the container starts (via `/setup-container.sh`). 

This function intelligently points to the correct kubeconfig file based on the current environment, which is determined by the `TF_VAR_environment` variable set in `/scripts/environment.sh`.

### Multi-Environment Support

This IAC environment supports deploying the OpenClone project to multiple environments:
- **vultr_dev** - Vultr development environment  
- **vultr_prod** - Vultr production environment

The OpenClone project can be deployed to any domain (e.g., clonezone.me) and the `k` function ensures you're always interacting with the correct Kubernetes cluster for your current environment context.

### Examples
```bash
# These commands automatically use the right kubeconfig:
k get pods
k describe deployment openclone-website
k logs -f deployment/openclone-sadtalker
k apply -f deployment.yaml
```

This eliminates the need to manually specify `--kubeconfig` flags and prevents accidentally running commands against the wrong cluster.

## Automated Deployment Workflow

**Primary Deployment Command:**
```bash
/scripts/cluster_create_and_destroy/create.sh --create
```

**DO NOT use direct `terraform apply`** - The OpenClone IAC system includes extensive automation logic that wraps Terraform.

### Deployment Sequence (`create.sh --create`)

The automated deployment follows this orchestrated sequence:

1. **Environment Setup**
   - Sets Terraform workspace based on `$TF_VAR_environment`

2. **Cluster Creation** (if needed)
   - Checks if cluster exists with `does_cluster_exist()`
   - Creates cluster via environment-specific scripts:
     - **Vultr**: `/scripts/cluster_create_and_destroy/vultr/cluster.sh`

3. **Terraform Initialization**
   - Runs `terraform init` in `/terraform` directory

4. **Longhorn Storage Installation**
   - Calls `install_longhorn()` from `/scripts/openclone-fs/longhorn/longhorn.sh`
   - Downloads and applies Longhorn YAML manifests
   - Installs NFS support for ReadWriteMany volumes
   - **Critical**: Storage system must be ready before workloads deploy

5. **Application Deployment via Terraform**
   - Runs `terraform apply -auto-approve` with dynamic variables:
     - `image_name_*`: Resolves current container image tags from registry
   - Deploys all OpenClone services with resolved image versions

### Container Image Resolution

The system automatically resolves the latest available container image tags:

**Tag Resolution Logic** (`/scripts/docker-cli/tag-resolver.sh`):
- **Vultr Environment**: Queries Vultr Container Registry for latest version tags
- **Version Format**: `X.0` (e.g., `1.0`, `2.0`, `3.0`)
- **Auto-Discovery**: Finds highest numbered tag that exists in registry

**Resolved Images Passed to Terraform**:
- `image_name_openclone_sadtalker`
- `image_name_openclone_u-2-net`  
- `image_name_openclone_database`
- `image_name_openclone_website`

### Storage System Race Condition

**Common Issue**: Workloads fail to schedule due to "unbound immediate PersistentVolumeClaims"

**Root Cause**: 
- Longhorn storage system needs several minutes to fully initialize
- PVCs request `longhorn-rwx` storage class immediately
- Storage provisioner not ready to fulfill requests yet
- Results in pods stuck in `Pending` state

**Solution Strategy**:
- **Retry deployment**: Same command often succeeds on second run after Longhorn is ready
- **Wait period**: Longhorn typically needs 5-10 minutes for full initialization
- **Verification**: Check `k get pods -n longhorn-system` for readiness

**Deployment Duration**:
- **Expected Time**: Full deployment can take **up to 1 hour** to complete
- **Do NOT cancel**: Long deployment times are normal for complete cluster setup
- **Progress Indicators**: Look for "Still creating..." rather than immediate failures

### Kubernetes Version Management

**Version Pinning Strategy**: The IAC system uses pinned Kubernetes versions in `/setup-container.sh` for deployment stability. 

**When "Invalid K8 version" errors occur:**
1. Check available versions: `curl -s -H "Authorization: Bearer $TF_VAR_vultr_api_key" "https://api.vultr.com/v2/kubernetes/versions" | jq -r ".versions[]"`
2. Update the version in `/setup-container.sh`: `set_env_variable kubernetes_version "v1.33.0+3"`
3. Reload with: `source /setup-container.sh`

**Why not auto-update?** While automatically fetching the latest version is technically feasible, manual version control prevents surprise failures from breaking changes in new Kubernetes releases. The occasional manual update is preferable to unpredictable deployment failures.

### Environment-Specific Behavior

**Vultr (Cloud Deployment)**:
- Queries Vultr Container Registry for image versions
- Full distributed storage with Longhorn
- External load balancers and DNS configuration
- Domain and SSL certificate management

This automated workflow ensures consistent, repeatable deployments while handling the complexities of container image versioning, storage provisioning, and environment-specific configurations.

## Host Command Execution

**Host Command Runner (PowerShell Buddy) for Windows Host Commands**

This devcontainer has a PowerShell companion script (referred to as the "PowerShell Buddy" or "Host Command Runner") that can execute commands on the Windows host environment when needed.

### How it works:
1. **Host Command Runner**: Located at `/IAC/scripts/devcontainer-host/host-command-runner.ps1`
2. **Command Interface**: Create a batch file at `/scripts/devcontainer-host/script-to-run.bat` with the Windows commands you want to execute
3. **Synchronous Execution**: The PowerShell buddy runs the batch file on the host and waits for completion
4. **Cleanup**: After execution, `script-to-run.bat` is automatically deleted

### When to use:
- Running Windows-specific commands that can't execute in the Linux container
- Accessing host-only resources or tools
- Managing Windows services or applications
- File operations that need Windows paths/permissions

### Example usage:
```bash
# Create a batch file with Windows commands
cat > /scripts/devcontainer-host/script-to-run.bat << 'EOF'
echo "Running on Windows host"
dir C:\
ipconfig /all
EOF

# The PowerShell buddy will automatically detect and execute it
# (The batch file will be deleted after execution)
```

This provides a bridge between the containerized IAC environment and the Windows host when necessary.




### Vultr Resource Management Limitations

**Terraform Destroy Limitations:**
When running `terraform destroy`, Vultr doesn't automatically clean up certain resources that were created during cluster provisioning:

- **Load Balancers** - Created by Kubernetes services but not destroyed by Terraform
- **DNS Records** - Managed by Terraform but cleanup behavior is conditional
- **VPC** - Automatically created by Vultr when cluster is created, but not managed by Terraform

**Manual Cleanup via Vultr API:**
The `/scripts/cluster_create_and_destroy/destroy.sh --destroy` script calls the Vultr API to manually delete these orphaned resources:

- **Always Deleted:** VPC and Load Balancers
- **Conditionally Deleted:** DNS records (logic depends on specific requirements)

This manual cleanup prevents resource accumulation and unexpected charges from resources that Terraform can't properly destroy on its own.

## IAC Architecture & Environment

### **Script Organization**
**Rule**: All logic belongs in `/scripts` directory
- **Modular Design**: Functionality separated into focused scripts
- **Reusable Components**: Shared logic across different deployment contexts
- **Function-Based Execution**: Scripts callable via `/scripts/shell-helpers/function-runner.sh`

**Function Runner Pattern**:
```bash
/scripts/myfile.sh --run_function "arg1" "arg2"
# Executes specific function within script with arguments
# Enables selective execution without running entire script
```

### **Container Initialization Sequence**
**Boot Chain**: `Dockerfile` → Dev Container Runtime → `.devcontainer.json`/`docker-compose.yaml` → `/setup-container.sh`

1. **Dockerfile**: Base image and system dependencies
2. **Dev Container Runtime**: VS Code dev container engine
3. **Configuration**: `.devcontainer.json` defines mounts, environment, and features
4. **Container Setup**: `/setup-container.sh` executes final configuration

**Host Integration Requirements**:
- **Directory Pass-through**: Host directories mounted for persistent state
- **Docker Socket**: `/var/run/docker.sock` for container-in-container operations
- **Environment Variables**: Host environment passed through for API keys and configuration
- **Network Access**: Host network connectivity for external service integration

### **Vultr API Wrapper**
**Location**: `/vultr-api` - Shell wrapper around Vultr REST API
- **Limited Implementation**: Only required endpoints implemented
- **Authentication**: API key-based access to Vultr services
- **Resource Management**: Instance, VPC, DNS, load balancer operations
- **Integration**: Used by provisioning scripts for infrastructure management

### **Dev Container Features**

**VS Code Integration**: `.devcontainer.json` defines custom taskbar buttons for:
- **Remote Shell Access**: Automatically opens shells in deployed environments
- **Docker Image Deployment**: Pushes container images to registries
- **Database Operations**: Migrations, backups, and restore operations
- **Infrastructure Management**: Terraform apply/destroy operations
- **Monitoring Access**: Direct links to Grafana and Longhorn dashboards

**One-Click Operations**:
- **Terraform Changes**: Modify `.tf` files → Click Apply button → Infrastructure updates
- **Container Deployment**: Code changes → Click Deploy button → Services updated
- **Environment Switching**: Click environment button → Context switches to target cluster

### **Monitoring & Storage**

**Grafana Integration**:
- **Cluster Monitoring**: Resource utilization, pod status, node health
- **Application Metrics**: Service-specific dashboards and alerts
- **Access Method**: Direct URLs from dev container taskbar
- **Configuration**: Automated setup via Kubernetes manifests

**Longhorn Storage Management**:
- **Distributed Storage**: Replicated block storage across cluster nodes
- **Volume Monitoring**: Disk usage, replica health, backup status
- **Web Interface**: Longhorn UI accessible from dev container
- **Backup Strategy**: Automated snapshots and external backup targets

### **Kubernetes Architecture**

**Current Implementation**:
- **Single Node Pool**: Simplified cluster configuration for development time constraints

**Scalability Groundwork**:
- **Multi-Node Ready**: Infrastructure patterns support cluster expansion (with some additional development work)

### **Environment Uniqueness**

**Comprehensive Solution**: IAC project evolved into complete quasi-development environment
- **Infrastructure as Code**: Terraform-managed cloud resources
- **Container Orchestration**: Kubernetes cluster management
- **Development Tools**: Integrated IDE, debugging, and monitoring
- **CI/CD Pipeline**: Automated build, test, and deployment workflows

**Dev Container Benefits**:
- **Consistent Environment**: Identical development setup across machines
- **Integrated Tooling**: All required tools pre-installed and configured
- **One-Click Operations**: Complex workflows reduced to button clicks
- **Team Collaboration**: Shared configuration ensures environment parity

This IAC environment represents a complete infrastructure-as-code solution that packages development environment, deployment tooling, monitoring, and cluster management into a single, portable development container.

## Claude Code Integration with IAC Container

### Command Execution from Host
Claude can execute commands inside the IAC dev container from the host environment using:

**Direct Command Execution:**
```bash
/StartStopScripts/Claude/iac-exec.sh "command"
```

**Examples:**
- `/StartStopScripts/Claude/iac-exec.sh "k get pods"` - Check Kubernetes pods
- `/StartStopScripts/Claude/iac-exec.sh "terraform plan"` - Run infrastructure planning  
- `/StartStopScripts/Claude/iac-exec.sh "/scripts/database/database.sh --backup"` - Execute database operations
- `/StartStopScripts/Claude/iac-exec.sh "ls /scripts"` - List available IAC scripts

### Shared IAC Terminal (tmux)

**VS Code Button Workflow:**
1. **User**: Click "Claude TMUX" button in VS Code status bar
2. **System**: Creates session with message "TMUX Session started. Ask claude to join session iac-shared"
3. **User**: Tell Claude "Join the IAC tmux session"
4. **Claude**: Enables logging and starts sending commands to shared session

**VS Code Button Command:**
```bash
tmux new-session -d -s iac-shared && tmux send-keys -t iac-shared 'echo "TMUX Session started. Ask claude to join session iac-shared"' Enter && tmux attach-session -t iac-shared
```

**Claude Interaction with IAC tmux:**
- **View terminal activity**: `/StartStopScripts/Claude/iac-exec.sh "tmux capture-pane -t iac-shared -p"`
- **Send commands**: `/StartStopScripts/Claude/iac-exec.sh "tmux send-keys -t iac-shared 'command' Enter"`
- **Enable logging**: `/StartStopScripts/Claude/iac-exec.sh "tmux pipe-pane -t iac-shared -o 'cat >> /tmp/iac-tmux-session.log'"`

### Container Environment
The IAC container includes:
- **kubectl** via `k` function (environment-aware kubeconfig)
- **terraform** for infrastructure management
- **vultr-api** scripts for cloud resource management
- **All IAC scripts** in `/scripts` directory
- **Environment variables** pre-configured for OpenClone deployment
- **tmux** for shared terminal sessions

### Usage Patterns

**Infrastructure Work:**
1. **User**: Click VS Code "Claude TMUX" button
2. **User**: Tell Claude "Join the IAC tmux session"
3. **Claude**: Enables logging and can execute commands like `/StartStopScripts/Claude/iac-exec.sh "k get nodes"`
4. **Collaboration**: Real-time shared terminal for cluster management

**Quick Commands:**
- Claude executes single commands without persistent session
- Example: `/StartStopScripts/Claude/iac-exec.sh "terraform validate"`
- No tmux session needed for one-off operations

