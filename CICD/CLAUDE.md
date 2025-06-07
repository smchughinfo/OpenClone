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
