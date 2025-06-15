# Claude Instructions for CICD Project

This file contains important information for Claude when working in the CICD devcontainer.

## Kubernetes Command Usage

**IMPORTANT: Use `k` instead of `kubectl`**

Always use the `k` function instead of the standard `kubectl` command. For example:
- Use: `k get pods`
- Not: `kubectl get pods`

### Why use `k`?

The `k` function is defined in `scripts/shell-helpers/aliases.sh` and automatically added to `~/.bashrc` when the container starts (via `/setup-container.sh`). 

This function intelligently points to the correct kubeconfig file based on the current environment, which is determined by the `TF_VAR_environment` variable set in `/scripts/environment.sh`.

### Multi-Environment Support

This CICD environment supports deploying the OpenClone project to multiple environments:
- **kind** - Local Kubernetes cluster
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

## Host Command Execution

**PowerShell Buddy for Windows Host Commands**

This devcontainer has a PowerShell companion script that can execute commands on the Windows host environment when needed.

### How it works:
1. **PowerShell Buddy**: Located at `/CICD/scripts/devcontainer-host/host-command-runner.ps1`
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

This provides a bridge between the containerized CICD environment and the Windows host when necessary.

## Server-0 Architecture

**Cost-Efficient On-Demand GPU Cluster Management**

The OpenClone project uses a two-tier architecture to minimize GPU hosting costs while maintaining user accessibility.

### The Problem
GPU clusters are expensive to run 24/7, but users need access to AI applications that require GPU resources.

### Architecture Options Considered

**Option 1: Always-On Hybrid CPU/GPU Cluster**
- Keep CPU nodes running 24/7, spin up GPU nodes on-demand
- More complex orchestration and resource management
- Would eventually scale to multiple nodes with dedicated CPU/GPU separation

**Option 2: Full On-Demand Cluster Creation** ✅ **Selected**
- Create entire cluster (CPU + GPU) only when users need it
- Simpler to implement for MVP
- Currently uses single powerful node, but could eventually scale to multi-node CPU/GPU separation
- Chosen to get project finished rather than over-engineering the architecture

### Two-Tier Implementation

**Server-0 (Always Running)**
- Cheap VPS hosting simple Node.js landing page ("CloneZone")
- Handles Google OAuth authentication and Stripe payments
- Always online to catch users, minimal hosting costs
- Located at `/Server-0/` in the codebase

**Server-0-Delta (Created On-Demand)**
- Only created after user payment verification
- Server-0 spins up Server-0-Delta using VPS snapshot via `/scripts/server-0/server-0.sh`
- More powerful instance needed for compute-intensive cluster creation
- Server-0-Delta creates the actual GPU Kubernetes cluster
- Temporary instance - destroyed when user session ends

### User Flow
1. User visits site → Server-0 serves landing page
2. User authenticates and pays → Server-0 validates payment
3. Server-0 creates Server-0-Delta instance
4. Server-0-Delta provisions GPU Kubernetes cluster
5. User gets access to OpenClone AI applications
6. After session timeout, both Server-0-Delta and GPU cluster are destroyed

### Cost Benefits
- GPU resources only consumed during active user sessions
- Server-0 stays cheap and always available as the "cluster vending machine"
- Server-0-Delta is temporary and only exists during active sessions
- Significant cost savings compared to 24/7 GPU cluster operation

This architecture treats Server-0 as a "cluster vending machine" that only dispenses expensive GPU resources after payment validation.

**Application Implementation Details**: See `/Server-0/CLAUDE.md` for Node.js application code, API endpoints, and technical implementation.

### CICD Container Reuse Strategy

**The CICD container gets extensive mileage across different contexts:**

1. **Local Development** - Used as a dev container for development work
2. **Server-0** - Runs CICD container to leverage existing variables and logic for creating Server-0-Delta instances
3. **Server-0-Delta** - Runs CICD container to provision the actual Kubernetes cluster

**Benefits of Shared CICD Code:**
- All infrastructure logic, variables, and scripts are centralized
- Server-0 can easily create Server-0-Delta because it already has all the provisioning logic
- Consistent tooling and environment across all deployment contexts
- Reduces code duplication and maintenance overhead

**Potential Complexity:**
- The overlap/underlap between different use cases could theoretically create blind spots
- Same container serves different purposes in different contexts
- However, in practice this approach has proven to be fairly sane and maintainable

This shared container strategy allows the CICD codebase to handle everything from local development to production cluster provisioning with a single, well-tested set of tools and scripts.

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

## CICD Architecture & Environment

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

**Comprehensive Solution**: CICD project evolved into complete quasi-development environment
- **Infrastructure as Code**: Terraform-managed cloud resources
- **Container Orchestration**: Kubernetes cluster management
- **Development Tools**: Integrated IDE, debugging, and monitoring
- **CI/CD Pipeline**: Automated build, test, and deployment workflows

**Dev Container Benefits**:
- **Consistent Environment**: Identical development setup across machines
- **Integrated Tooling**: All required tools pre-installed and configured
- **One-Click Operations**: Complex workflows reduced to button clicks
- **Team Collaboration**: Shared configuration ensures environment parity

This CICD environment represents a complete infrastructure-as-code solution that packages development environment, deployment tooling, monitoring, and cluster management into a single, portable development container.

## Claude Code Integration with CICD Container

### Command Execution from Host
Claude can execute commands inside the CICD dev container from the host environment using:

**Direct Command Execution:**
```bash
/StartStopScripts/Claude/cicd-exec.sh "command"
```

**Examples:**
- `/StartStopScripts/Claude/cicd-exec.sh "k get pods"` - Check Kubernetes pods
- `/StartStopScripts/Claude/cicd-exec.sh "terraform plan"` - Run infrastructure planning  
- `/StartStopScripts/Claude/cicd-exec.sh "/scripts/database/database.sh --backup"` - Execute database operations
- `/StartStopScripts/Claude/cicd-exec.sh "ls /scripts"` - List available CICD scripts

### Shared CICD Terminal (tmux)

**VS Code Button Workflow:**
1. **User**: Click "Claude TMUX" button in VS Code status bar
2. **System**: Creates session with message "TMUX Session started. Ask claude to join session cicd-shared"
3. **User**: Tell Claude "Join the CICD tmux session"
4. **Claude**: Enables logging and starts sending commands to shared session

**VS Code Button Command:**
```bash
tmux new-session -d -s cicd-shared && tmux send-keys -t cicd-shared 'echo "TMUX Session started. Ask claude to join session cicd-shared"' Enter && tmux attach-session -t cicd-shared
```

**Claude Interaction with CICD tmux:**
- **View terminal activity**: `/StartStopScripts/Claude/cicd-exec.sh "tmux capture-pane -t cicd-shared -p"`
- **Send commands**: `/StartStopScripts/Claude/cicd-exec.sh "tmux send-keys -t cicd-shared 'command' Enter"`
- **Enable logging**: `/StartStopScripts/Claude/cicd-exec.sh "tmux pipe-pane -t cicd-shared -o 'cat >> /tmp/cicd-tmux-session.log'"`

### Container Environment
The CICD container includes:
- **kubectl** via `k` function (environment-aware kubeconfig)
- **terraform** for infrastructure management
- **vultr-api** scripts for cloud resource management
- **All CICD scripts** in `/scripts` directory
- **Environment variables** pre-configured for OpenClone deployment
- **tmux** for shared terminal sessions

### Usage Patterns

**Infrastructure Work:**
1. **User**: Click VS Code "Claude TMUX" button
2. **User**: Tell Claude "Join the CICD tmux session"
3. **Claude**: Enables logging and can execute commands like `/StartStopScripts/Claude/cicd-exec.sh "k get nodes"`
4. **Collaboration**: Real-time shared terminal for cluster management

**Quick Commands:**
- Claude executes single commands without persistent session
- Example: `/StartStopScripts/Claude/cicd-exec.sh "terraform validate"`
- No tmux session needed for one-off operations
