# Use Ubuntu 24.04 LTS base image
FROM ubuntu:24.04

# Set the time zone environment variable
ENV TZ=America/New_York

# Install necessary packages
RUN apt-get update && \
    apt-get install -y curl gnupg software-properties-common gettext-base && \
    apt-get install -y jq && \
    apt-get install -y jo

# Install Node.js (using NodeSource repository for latest LTS)
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - && \
    apt-get install -y nodejs

# Install Claude Code globally
RUN npm install -g @anthropic-ai/claude-code

# Add HashiCorp GPG key and repository
RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | \
    gpg --dearmor | \
    tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null && \
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
    https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
    tee /etc/apt/sources.list.d/hashicorp.list

# Install Terraform
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y terraform

# Install kubectl (make sure this matches the kubernetes_version environment variable)
RUN curl -LO "https://dl.k8s.io/release/v1.33.0/bin/linux/amd64/kubectl" 
RUN mkdir -p /usr/local/bin/kubectl
RUN mv kubectl /usr/local/bin/kubectl/kubectl
RUN chmod +x /usr/local/bin/kubectl/kubectl
ENV PATH=$PATH:/usr/local/bin/kubectl

# Install Docker CLI (this is so you can run the host's docker inside the container)
RUN apt-get update
RUN apt-get install -y docker.io

# Install PostgreSQL (used for verifying database connectivity)
RUN apt-get install -y postgresql

# Install LFTP to FTP OpenCloneFS
RUN apt-get install -y lftp

# Install lsof (used for port forwarding in Prometheus and Grafana)
RUN apt-get install -y lsof

# Install Kind
RUN curl -Lo /usr/local/bin/kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64 && \
    chmod +x /usr/local/bin/kind

# Install Locales (this is for connecting to postgres on kind)
RUN apt-get install -y locales && \
    locale-gen en_US.UTF-8 && \
    dpkg-reconfigure locales && \
    locale-gen en_US.UTF-8

# Install yq (this is a yaml processor, used to set server field in kube-config in kind to "kubernetes" which matches an entry for kubernetes in /etc/hosts (gets around helm tls requirements when installing prometheus))
RUN curl -L https://github.com/mikefarah/yq/releases/download/v4.35.1/yq_linux_amd64 -o /usr/local/bin/yq && \
    chmod +x /usr/local/bin/yq

# Install ping command
RUN apt-get install iputils-ping

# Install envsubst
RUN apt-get update
RUN apt-get install gettext -y

# Server-0
RUN apt-get install sshpass -y

# Keep the container running
CMD ["tail", "-f", "/dev/null"]