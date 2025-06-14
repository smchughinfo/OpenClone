# OpenClone

[![Video Intro](https://img.youtube.com/vi/-HNyzIxsI2c/0.jpg)](https://youtu.be/-HNyzIxsI2c)

Create AI-powered digital clones that talk, think, and interact just like you! OpenClone uses cutting-edge deepfake technology to bring your personal AI avatars to life.

## Component Overview

OpenClone is a distributed system of specialized components working together:

### 🌐 **Website** (ASP.NET Core)
The main web interface where users create and interact with their digital clones. Features user authentication, clone management, real-time chat, and video generation orchestration.

### 🗄️ **Database** (PostgreSQL + pgVector)
Dual-database architecture with the main OpenClone database for user data and clones, plus a separate logging database. Supports vector embeddings for AI personality matching.

### 🎭 **SadTalker** (Python + GPU)
AI-powered deepfake video generation service that creates realistic talking head videos from still images and audio. Requires NVIDIA GPU for optimal performance.

### 🖼️ **U-2-Net** (Python + GPU) 
Advanced image segmentation service that automatically removes backgrounds from user photos and performs image preprocessing for clone creation.

### 📊 **LogViewer** (Python Flask)
Real-time monitoring dashboard that provides system insights, error tracking, and performance metrics across all OpenClone components.

### 🔧 **CICD** (Kubernetes + Terraform)
Complete DevOps infrastructure for deploying OpenClone to cloud environments, including Kubernetes clusters, databases, and monitoring systems.

### 🤖 **Claude Code Integration**
Specialized tooling for repository exploration and development collaboration using Anthropic's Claude Code, including automated screenshot sharing and documentation analysis.

## Working with This Repository

This project is designed to work seamlessly with **Claude Code** - Anthropic's AI coding assistant. The repository includes extensive Claude-specific documentation and integration tools:

### 🚀 **Quick Start with Claude Code**
1. Open this repository in Claude Code
2. Run `/OpenClone/StartStopScripts/Claude/start.bat` for shared development environment
3. Use the `cr` command anytime to have Claude analyze and update documentation

### 🔍 **Repository Intelligence**
- **Automatic Documentation Sync**: Claude keeps README and CLAUDE.md files synchronized with code changes
- **Shared Terminal**: Real-time collaboration through tmux sessions  
- **Screenshot Integration**: Instant visual communication with automatic clipboard capture
- **Component Analysis**: Deep understanding of multi-service architecture

*For the best development experience, we highly recommend using Claude Code to explore and understand this repository's architecture.*

## What is OpenClone?

OpenClone lets you build personalized AI clones that can:
- 🗣️ **Talk like you** - Train with your voice for realistic speech
- 🎭 **Look like you** - Create lifelike video avatars 
- 🧠 **Think like you** - Learn from Q&A sessions to capture your personality
- 💬 **Chat naturally** - Have conversations that feel authentic

Perfect for content creators, educators, businesses, or anyone who wants to create their digital twin!

## Quick Start

Ready to create your first clone? Here's how:

### Option 1: Full Setup (Recommended)
1. **Download** - Clone this repository to your computer
2. **Configure** - Set up the environment variables below 
3. **Launch** - Run `StartStopScripts/run-all.bat` to start everything
4. **Create** - Visit `http://localhost:8080` and build your first clone!

### Option 2: Step-by-Step
Want to start individual services? Use these batch files:
- `StartStopScripts/Database/start.bat` - Start the database
- `StartStopScripts/SadTalker/start.bat` - Start video generation
- `StartStopScripts/U-2-Net/start.bat` - Start background removal
- `StartStopScripts/OpenClone/start.bat` - Start the main website

## What You'll Need

### Required Software
- **Docker Desktop** - For running all the AI services
- **NVIDIA GPU** (recommended) - Makes video generation much faster
- **Node.js** - For the website frontend

### API Keys (Get these free accounts)
- **OpenAI API Key** - For AI conversations ([Get one here](https://platform.openai.com/api-keys))
- **ElevenLabs API Key** - For voice cloning ([Get one here](https://elevenlabs.io/))
- **Google OAuth** - For user login ([Setup guide](https://developers.google.com/identity/protocols/oauth2))

## How It Works

1. **Create Your Clone** - Upload a photo and record some audio samples
2. **Train the AI** - Answer questions to teach your clone how to respond
3. **Generate Videos** - Watch your clone come to life in realistic talking videos
4. **Chat & Share** - Have conversations with your clone or let others chat with it

## Features

- 🎯 **Easy Setup** - Get started in minutes with our batch scripts
- 🔒 **Privacy First** - Your data stays on your computer
- 🎨 **Customizable** - Train your clone's personality and responses
- 📱 **Web Interface** - Works in any modern web browser
- 🚀 **Fast Generation** - Optimized for quick video creation
- 💾 **Export Options** - Download your clone videos and conversations

## Getting Help

- 📖 **Documentation** - Check the individual component README files for detailed setup
- 🐛 **Issues** - Found a bug? Create an issue in this repository
- 💡 **Questions** - Need help? Create an issue and we'll assist you


---

Ready to create your digital twin? Let's get started! 🚀

## Environment Variables Setup

Copy these settings and update with your own values. You can set these in your system environment or create a `.env` file:

### Required API Keys
```bash
# AI Services (Required)
OpenClone_OPENAI_API_KEY=<your-openai-api-key>
OpenClone_ElevenLabsAPIKey=<your-elevenlabs-api-key>

# Google Login (Required)
OpenClone_GoogleClientId=<your-google-client-id>
OpenClone_GoogleClientSecret=<your-google-client-secret>

# Security (Generate a random string)
OpenClone_JWT_SecretKey=<your-jwt-secret-key>
```

### Database Settings (Default values work for local development)
```bash
# Database Configuration
OpenClone_DB_Host=192.168.0.100
OpenClone_DB_Port=5433
OpenClone_Postgres_Password=puppies
OpenClone_postgres_superuser_password=openclone-super

# Main Database
OpenClone_OpenCloneDB_Name=open_clone
OpenClone_OpenCloneDB_User=openclone
OpenClone_openclonedb_password=kittens
OpenClone_DefaultConnection=Host=192.168.0.100;Port=5433;Database=open_clone;Username=openclone;Password=kittens;Include Error Detail=true;
OpenClone_DefaultConnection_Super=Host=192.168.0.100;Port=5433;Database=open_clone;Username=postgres;Password=openclone-super;Include Error Detail=true;

# Logging Database
OpenClone_LogDB_Name=open_clone_logging
OpenClone_LogDB_User=logs
OpenClone_logdb_password=bunnies
OpenClone_LogDbConnection=Host=192.168.0.100;Port=5433;Database=open_clone_logging;Username=logs;Password=bunnies;
OpenClone_LogDbConnection_Super=Host=192.168.0.100;Port=5433;Database=open_clone_logging;Username=postgres;Password=openclone-super;
```

### Miscellaneous Settings
```bash
# Your Information
OpenClone_Admin_Email=<your@email.com>
OpenClone_JWT_Issuer=https://www.clonezone.me
OpenClone_JWT_Audience=OpenClone

# File Storage (Update paths for your system)
OpenClone_Root_Dir=C:/Users/seanm/Desktop/OpenClone
OpenClone_OpenCloneFS=C:/Users/seanm/Desktop/OpenClone/OpenCloneFS

# AI Service Endpoints (Default local addresses)
OpenClone_SadTalker_HostAddress=http://127.0.0.1:5001
OpenClone_U2Net_HostAddress=http://127.0.0.1:5002

# Email (Optional - for DKIM)
OpenClone_email_dkim=v=<your-dkim-public-key>
OpenClone_ZOHO_EMAIL_PASSWORD=<your-zoho-password>

# Cloud Deployment (Optional - for Vultr hosting)
OpenClone_Vultr_API_Key=<your-vultr-api-key>
OpenClone_Server_0_IP_Address=<your-server-ip>
OpenClone_Server_0_Password=<your-server-password>

# System Settings
OpenClone_CUDA_VISIBLE_DEVICES=0,1
OpenClone_OpenCloneLogLevel=Information
OpenClone_SystemLogLevel=Error
```
