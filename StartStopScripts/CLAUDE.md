# StartStopScripts - Development Environment Automation

## Overview
Collection of Windows batch scripts providing quick startup/shutdown operations for OpenClone project components. Designed for **local development** using Docker containers and Python applications on Windows systems.

## Architecture

### **Orchestration Pattern**
**Dependencies**: Docker Desktop → Database → LogViewer → WebPack → AI Services → Main Website
**Philosophy**: Stop-then-start pattern ensures clean state, container reuse for faster startup

### **Container Naming Convention**
All containers follow `openclone-*` prefix:
- `openclone-database` (PostgreSQL on port 5433)
- `openclone-website` (ASP.NET Core on port 8080)  
- `openclone-sadtalker` (AI service on port 5001)
- `openclone-u-2-net` (Image processing on port 5002)

## Script Categories

### **Main Orchestration**
**run-all.bat**: Single-command startup for entire development environment
- **Current Issue**: References incorrect paths (`../BatchScripts/` instead of current directory)
- **Sequence**: Launches all components in dependency order
- **Pattern**: Stops then starts each service for clean state

### **Infrastructure Scripts**

**Docker/start.bat**: Launches Docker Desktop and waits for daemon readiness
```batch
start "Docker Desktop" "C:\Program Files\Docker\Docker\Docker Desktop.exe"
# Polls 'docker ps' until CONTAINER text appears
```

**Database/start.bat**: PostgreSQL container with smart reuse logic
```batch
# Uses openclone-database:1.0 image
# Port 5433 (not default 5432)
# Environment variables for credentials and configuration
# Supports both main OpenClone DB and logging DB
```

### **Application Services**

**OpenClone/start.bat**: Main ASP.NET Core website
- **Port**: 8080 → container port 80
- **Dependencies**: Requires SadTalker and U-2-Net services running
- **Configuration**: Extensive environment variable setup (JWT, APIs, database)
- **File System**: Mounts OpenCloneFS for shared file storage

**SadTalker/start.bat**: AI-powered talking head generation
- **Technology**: Python service with GPU support (`--gpus all`)
- **Port**: 5001
- **GPU Requirements**: CUDA environment variables
- **Smart Logic**: Reuses existing container if available

**U-2-Net/start.bat**: Background removal and image segmentation  
- **Technology**: Python service with GPU support
- **Port**: 5002
- **Container Reuse**: Checks for existing container before creating new one

### **Development Tools**

**WebPack/start.bat**: Frontend development server
```batch
cd /d "%~dp0../../Website/OpenClone.UI/"
npm run dev
```

**LogViewer Scripts**: Python Flask monitoring application
- **start-local.bat**: Local development environment
- **start-kind.bat**: Kubernetes (kind) development  
- **start-remote.bat**: Remote/production environments
- **Path**: Uses Python virtual environment at `../../LogViewer/.venv/`

### **Claude Code Integration**

**Claude/start.bat**: Unified Claude Code development environment launcher
- **Functionality**: Launches Claude Code, creates shared tmux session, starts screenshot watcher
- **Components**: Integrates three separate tools for seamless Claude Code collaboration
- **Output**: Three separate windows (Claude Code, tmux terminal, screenshot watcher)

**Claude/screenshot-watcher.ps1**: Automatic screenshot capture system
- **Technology**: PowerShell clipboard monitoring with duplicate detection
- **Functionality**: Automatically saves clipboard screenshots to `Screenshots/` directory
- **Features**: MD5 hash-based duplicate prevention, auto-cleanup on startup, mutex-based single instance
- **Integration**: Works with Claude Code's image reading capabilities

**Claude/stop.bat**: Cleanup script for Claude Code tools
- **Functionality**: Terminates tmux session and screenshot watcher processes
- **Safety**: Preserves Claude Code instance to prevent chat history loss

## Environment Dependencies

### **Required Environment Variables** (OpenClone_ prefix)
**Database**: Connection strings, credentials
**Authentication**: JWT configuration, Google OAuth
**APIs**: OpenAI, ElevenLabs API keys
**Services**: SadTalker, U-2-Net host addresses
**File System**: OpenCloneFS path

### **System Requirements**
- **Windows** with Docker Desktop
- **NVIDIA Docker support** for GPU-dependent AI services
- **Node.js** for WebPack development server
- **Python** virtual environments for LogViewer

## Known Issues & Technical Debt

### **Critical Issues**
1. **run-all.bat path bug**: References non-existent `../BatchScripts/` directory
2. **WebPack stop.bat**: Kills all Node processes (too aggressive)
3. **LogViewer paths**: Reference `../../logviewer/` but should be `../../LogViewer/` (case sensitivity)

### **Architecture Limitations**
- **Local development only** - not suitable for production deployment
- **Windows-specific** batch script format
- **Interactive terminal windows** prevent automation
- **GPU hardware dependency** for AI services

### **Recommended Improvements**
1. **Fix path references** in run-all.bat
2. **Refined stop mechanisms** for WebPack (target specific processes)
3. **Cross-platform support** with shell script equivalents
4. **Environment validation** checks before startup
5. **Service health checks** and startup verification

## Usage Patterns

### **Full Development Environment**
```batch
# Start everything (after fixing path issues)
run-all.bat

# Individual components
Database\start.bat
SadTalker\start.bat
U-2-Net\start.bat
OpenClone\start.bat
```

### **Selective Development**
```batch
# Core services only
Docker\start.bat
Database\start.bat
WebPack\start.bat

# Add AI services as needed
SadTalker\start.bat
U-2-Net\start.bat
```

### **Shutdown**
```batch
# Individual service stops
Database\stop.bat
SadTalker\stop.bat
U-2-Net\stop.bat
WebPack\stop.bat

# Docker cleanup
Docker\close-docker-desktop.bat
```

## File Structure
```
StartStopScripts/
├── run-all.bat                 # Main orchestration (needs fixes)
├── Claude/                     # Claude Code integration tools
│   ├── Screenshots/            # Auto-captured screenshots for sharing with Claude
│   ├── claude-refactor.sh      # Repository analysis script
│   ├── screenshot-watcher.ps1  # Clipboard screenshot monitoring
│   ├── start.bat              # Launch Claude Code + shared terminal + screenshot watcher
│   └── stop.bat               # Stop tmux session and screenshot watcher
├── Database/                   # PostgreSQL container management
├── Docker/                     # Docker Desktop lifecycle
├── LogViewer/                  # Flask monitoring app (3 environments)
├── OpenClone/                  # Main website container
├── SadTalker/                  # AI deepfake service
├── U-2-Net/                    # Image processing service
└── WebPack/                    # Frontend development server
```

**Purpose**: Eliminates manual Docker commands and environment setup, provides one-click development environment for OpenClone contributors.