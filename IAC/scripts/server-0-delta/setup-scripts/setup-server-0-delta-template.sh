
#!/bin/bash
set -e

################################################################################
######## DOCKER INSTALLATION ####################################################
################################################################################

echo "Installing Docker on Ubuntu..."

# Update system
apt-get update
apt-get upgrade -y

# Install prerequisites
apt-get install -y ca-certificates curl gnupg lsb-release

# Add Docker's official GPG key
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Add Docker repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Start and enable Docker
systemctl start docker
systemctl enable docker

# Add root user to docker group (for convenience)
usermod -aG docker root

# Create completion marker
touch /var/log/docker-install-complete

echo "Docker installation completed successfully!"

################################################################################
######## ENVIRONMENT VARIABLES #################################################
################################################################################

setenv() {
    if [ $# -ne 2 ]; then
        echo "Usage: setenv VARIABLE_NAME value"
        return 1
    fi
    
    local var_name="$1"
    local var_value="$2"
    
    # Create profile.d directory if it doesn't exist
    [ ! -d /etc/profile.d ] && mkdir -p /etc/profile.d
    
    # Remove existing entries first to prevent duplicates
    sed -i "/^export ${var_name}=/d" /etc/profile.d/openclone.sh 2>/dev/null || true
    
    # Save to persistent file
    echo "export ${var_name}='${var_value}'" >> /etc/profile.d/openclone.sh
    
    # Export for immediate use
    export "${var_name}=${var_value}"
    
    echo "Set ${var_name} successfully"
}

echo "setup-server-0-delta complete!"
