# CICD - OpenClone Infrastructure & Development Environment

[![OpenClone CICD Overview](https://img.youtube.com/vi/SMhwddNQSWQ/0.jpg)](https://www.youtube.com/watch?v=SMhwddNQSWQ)

## What is this?

This is a VS Code dev container that contains the infrastructure automation and deployment tooling for the OpenClone project. It packages Terraform configurations, Kubernetes manifests, shell scripts, and monitoring tools into a containerized development environment. The container includes custom VS Code tasks accessible via status bar buttons for common operations like applying Terraform changes, pushing Docker images, and managing cluster resources.

The infrastructure is designed around Vultr cloud resources and supports multiple deployment environments (local kind clusters, development, and production). All deployment logic lives in the `/scripts` directory and uses a function-based execution pattern via shell helpers.

## How to run it

Open this project in VS Code with the Dev Containers extension. The container runs as a standard dev container with pre-installed tools (Terraform, kubectl, etc.). You'll need to set the required environment variables - see the root level README.md for the complete list of environment variables to configure.

For more technical details and architecture information, see [CLAUDE.md](CLAUDE.md).
