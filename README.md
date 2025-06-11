![Splash Image](Documentation/splash.png)

# OpenClone

An AI-powered clone system with deepfake capabilities and comprehensive infrastructure automation.

## Environment Variables

The following environment variables must be set for proper operation. Set these in your system environment or in a `.env` file:

### Database Configuration
```bash
# Database connection settings
OpenClone_DB_Host=192.168.0.100              # Your database host IP
OpenClone_DB_Port=5433                        # Database port
OpenClone_Postgres_Password=puppies           # PostgreSQL superuser password
OpenClone_postgres_superuser_password=openclone-super

# Main application database
OpenClone_OpenCloneDB_Name=open_clone
OpenClone_OpenCloneDB_User=openclone
OpenClone_openclonedb_password=kittens
OpenClone_DefaultConnection=Host=192.168.0.100;Port=5433;Database=open_clone;Username=openclone;Password=kittens;Include Error Detail=true;
OpenClone_DefaultConnection_Super=Host=192.168.0.100;Port=5433;Database=open_clone;Username=postgres;Password=openclone-super;Include Error Detail=true;

# Logging database
OpenClone_LogDB_Name=open_clone_logging
OpenClone_LogDB_User=logs
OpenClone_logdb_password=bunnies
OpenClone_LogDbConnection=Host=192.168.0.100;Port=5433;Database=open_clone_logging;Username=logs;Password=bunnies;
OpenClone_LogDbConnection_Super=Host=192.168.0.100;Port=5433;Database=open_clone_logging;Username=postgres;Password=openclone-super;
```

### Authentication & Security
```bash
# JWT Configuration
OpenClone_JWT_Audience=OpenClone
OpenClone_JWT_Issuer=https://www.clonezone.me  # Your domain
OpenClone_JWT_SecretKey=<your-jwt-secret>      # Generate a secure random key

# Google OAuth
OpenClone_GoogleClientId=<your-google-client-id>
OpenClone_GoogleClientSecret=<your-google-client-secret>

# Email DKIM
OpenClone_email_dkim=v=<your-dkim-public-key>
OpenClone_ZOHO_EMAIL_PASSWORD=<your-zoho-password>
```

### AI Services
```bash
# OpenAI API
OpenClone_OPENAI_API_KEY=<your-openai-api-key>

# ElevenLabs for voice synthesis
OpenClone_ElevenLabsAPIKey=<your-elevenlabs-api-key>

# AI service endpoints
OpenClone_SadTalker_HostAddress=http://127.0.0.1:5001  # Deepfake video service
OpenClone_U2Net_HostAddress=http://127.0.0.1:5002      # Background removal service
```

### Infrastructure
```bash
# File system paths
OpenClone_Root_Dir=C:/Users/seanm/Desktop/OpenClone     # Repository location
OpenClone_OpenCloneFS=C:/Users/seanm/Desktop/OpenClone/OpenCloneFS  # File storage

# FTP/SFTP Configuration
OpenClone_FTP_User=openclone-ftp
OpenClone_FTP_Password=abc123

# Cloud Infrastructure (Vultr)
OpenClone_Vultr_API_Key=<your-vultr-api-key>
OpenClone_Server_0_IP_Address=149.28.35.104    # From Vultr dashboard
OpenClone_Server_0_Password=<vultr-server-password>  # From Vultr dashboard
```

### System Configuration
```bash
# GPU Configuration
OpenClone_CUDA_VISIBLE_DEVICES=0,1            # Available GPU devices

# Logging levels
OpenClone_OpenCloneLogLevel=Information        # Application log level
OpenClone_SystemLogLevel=Error                 # System log level
```

## Quick Start

**Option 1: Full Infrastructure Development (Recommended)**
1. Clone this repository
2. Set all required environment variables above
3. Open the `/CICD/` project in VS Code as a dev container
4. Use the custom action buttons in the VS Code status bar to deploy infrastructure
5. Container includes Terraform, kubectl, monitoring tools, and one-click operations

**Option 2: Local Service Development**
1. Set environment variables from above
2. Use `/StartStopScripts/` batch files for individual service management:
   - `run-all.bat` - Starts complete development environment
   - `Database/start.bat` - PostgreSQL container on port 5433
   - `SadTalker/start.bat` - AI video generation service on port 5001
   - `U-2-Net/start.bat` - Background removal service on port 5002
   - `OpenClone/start.bat` - Main website on port 8080
   - `LogViewer/start-local.bat` - Log monitoring on port 1234

**Option 3: Component-Specific Development**
1. Follow individual component README files for targeted development
2. Each component includes setup instructions and environment requirements

## Architecture

OpenClone uses a microservices architecture designed for cost-efficient AI application deployment:

### Core Application Services
- **Website** (.NET 8 ASP.NET Core, port 8080): Main web application with hybrid Razor Pages + React architecture, orchestrating all backend services
- **Database** (PostgreSQL, port 5433): Database management with dual connection strings (super user for migrations, regular for application), bootstrap data management, and OpenCloneFS coordination
- **SadTalker** (Python Flask, port 5001): AI deepfake video generation with M3U8 HLS streaming, animation parameter caching, and GPU acceleration
- **U-2-Net** (Python Flask, port 5002): AI background removal with configurable threshold processing and custom mask application

### Infrastructure Services
- **Server-0** (Node.js Express, port 3000): Always-on cluster vending machine handling Google OAuth, Stripe payments, and on-demand GPU cluster provisioning
- **LogWeaver** (Python Package): Asynchronous database-backed logging with queue management and run number tracking for session organization
- **LogViewer** (Flask/React, port 1234): Real-time log monitoring with color-coded interface, HTML content support, and multi-environment targeting

### Development & Deployment Tools
- **CICD** (VS Code Dev Container): Complete infrastructure automation with Terraform, Kubernetes tools, Grafana monitoring, and custom status bar integration
- **StartStopScripts** (Windows Batch): Local development service lifecycle management with Docker container automation
- **OpenClone-DevContainer-StatusBar** (VS Code Extension): Published extension for environment identification and development context switching

### Integration Patterns
- **Shared File System**: OpenCloneFS provides centralized file access across all containers
- **Unified Logging**: All services write to centralized PostgreSQL logging database via LogWeaver
- **Service Orchestration**: Website coordinates AI services (SadTalker, U-2-Net) with external APIs (OpenAI, ElevenLabs)
- **Container Reuse**: CICD container serves multiple contexts (local development, Server-0 provisioning, Server-0-Delta cluster creation)

## Project Structure

### Core Application Components
- **Website/**: Main .NET 8 ASP.NET web application with hybrid Razor Pages + React architecture
- **Database/**: PostgreSQL database management with Python scripts for migrations, backup/restore, and OpenCloneFS management
- **SadTalker/**: AI deepfake video generation service with M3U8 HLS streaming (Flask API on port 5001)
- **U-2-Net/**: AI background removal service with configurable threshold processing (Flask API on port 5002)

### Infrastructure & Development Tools
- **CICD/**: Complete infrastructure automation and VS Code dev container environment with Terraform, Kubernetes tools, and custom status bar integration
- **Server-0/**: Always-on Node.js cluster vending machine for cost-efficient on-demand GPU provisioning
- **StartStopScripts/**: Windows batch scripts for local development service lifecycle management

### Supporting Services & Tools
- **LogWeaver/**: Custom Python logging package providing asynchronous database-backed logging with queue management
- **LogViewer/**: Flask/React real-time log monitoring web application with color-coded interface and HTML content support
- **OpenClone-DevContainer-StatusBar/**: Published VS Code extension for development environment identification and status bar customization

## Prerequisites

**Required Software:**
- **Docker Desktop** with WSL2 enabled (Windows) or Docker Engine (Linux)
- **VS Code** with Dev Containers extension
- **NVIDIA GPU drivers** supporting CUDA 11.8 (for AI services)
- **Node.js** (for Server-0 and Website frontend development)
- **Python 3.8.8-3.11.5** (for AI services and database management)

**Development Environment Specific:**
- **CICD**: Terraform, kubectl, and Kubernetes tools (auto-installed in dev container)
- **Database**: PostgreSQL client tools, VS Code PostgreSQL extension
- **SadTalker**: CUDA Toolkit 11.8, PyTorch with CUDA support
- **U-2-Net**: CUDA Toolkit 11.2.2+ (container uses 11.2.2, development can use 11.8)
- **Website**: .NET 8 SDK, npm/webpack for frontend builds

**VS Code Extensions (Per Component):**
- Database: [ckolkman.vscode-postgres](https://marketplace.visualstudio.com/items?itemName=ckolkman.vscode-postgres)
- CICD: Built-in dev container tools
- LogViewer: Python environment support
- Server-0: [Remote - SSH](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh)

**VS Code Themes (Optional):**
- Database: [Cyberpunk 2077 rebuild](https://vscodethemes.com/e/carlos18mz.cyberpunk-2077-rebuild/cyberpunk-2077-rebuild)
- LogViewer: [solvable.shades](https://vscodethemes.com/e/Solvable.shades/shades)
- SadTalker: [Shades of Purple](https://vscodethemes.com/e/ahmadawais.shades-of-purple/shades-of-purple)
- U-2-Net: [Candy](https://vscodethemes.com/e/meganrogge.candy-theme/candy?language=javascript)
- Server-0: [Doki Theme: AzurLane: Essex](https://vscodethemes.com/e/unthrottled.doki-theme/doki-theme-azurlane-essex)

## Documentation

Each component includes comprehensive documentation designed for technical audiences:

### Component Documentation
- **README.md** - Setup instructions, environment variables, and usage patterns
- **CLAUDE.md** - Technical architecture, implementation details, and integration points

### Key Technical Documentation
- **Website/CLAUDE.md**: Three-layer architecture (.NET Core/Services/UI), hybrid Razor+React approach, custom authorization policies, service patterns
- **Database/CLAUDE.md**: PostgreSQL with pgvector, dual connection security model, bootstrap system, OpenCloneFS management
- **SadTalker/CLAUDE.md**: M3U8 HLS streaming implementation, animation parameter caching, licensing considerations
- **U-2-Net/CLAUDE.md**: Background removal pipeline, threshold processing, model quality assessment
- **CICD/CLAUDE.md**: Multi-environment Kubernetes management, Server-0 architecture, container reuse strategy
- **LogWeaver/CLAUDE.md**: Asynchronous logging architecture, queue management, threading model
- **Server-0/CLAUDE.md**: Cluster vending machine implementation, OAuth integration, payment processing

### Video Documentation
Each component README includes placeholder video links for overview demonstrations