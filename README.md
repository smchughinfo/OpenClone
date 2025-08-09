# OpenClone

### Live Demo
[https://clonezone.me](https://clonezone.me)

## Application Flow

![Architecture](Documentation/architecture.png)

## Application Flow

![Application Flow 1](Documentation/application-flow-1.png)
![Application Flow 2](Documentation/application-flow-2.png) 
![Application Flow 3](Documentation/application-flow-3.png)
![Application Flow 4](Documentation/application-flow-4.png)

## What Is OpenClone

OpenClone lets you build personalized AI clones that can:
- 🗣️ **Talk like you** - Train with your voice for realistic speech
- 🎭 **Look like you** - Create lifelike video avatars 
- 🧠 **Think like you** - Learn from Q&A sessions to capture your personality
- 💬 **Chat naturally** - Have conversations that feel authentic

Perfect for content creators, educators, businesses, or anyone who wants to create their digital twin!

## Component Overview

OpenClone is a distributed system of specialized components working together:

### 🌐 **Website** (ASP.NET Core)
The main web interface where users create and interact with their digital clones. Features user authentication, clone management, chat, and video generation orchestration.

### 🗄️ **Database** (PostgreSQL + pgVector)
Dual-database architecture with the main OpenClone database for user data and clones, plus a separate logging database. Supports vector embeddings for AI personality matching.

### 🎭 **SadTalker** (Python + GPU)
AI-powered deepfake video generation service that creates realistic talking head videos from still images and audio. Requires NVIDIA GPU for optimal performance.

### 🖼️ **U-2-Net** (Python + GPU) 
Image segmentation service that removes backgrounds from user photos and performs image preprocessing for clone creation.

### 📊 **LogViewer** (Python Flask)
Monitoring dashboard that provides system insights, error tracking, and performance metrics across all OpenClone components.

### 🔧 **Deployment/IAC** (Kubernetes + Terraform)
DevOps infrastructure for deploying OpenClone to cloud environments, including Kubernetes clusters, databases, and monitoring systems.

**Note on Kubernetes Versions**: The IAC system uses pinned Kubernetes versions for stability. If deployment fails with "Invalid K8 version" errors, check available versions with the Vultr API and update the version in `/Deployment/IAC/setup-container.sh`. While auto-updating to latest versions is possible, manual version control prevents unexpected breaking changes from new Kubernetes releases.

### 🤖 **Code Assistant Integrattion**
Technical documentation and context files for AI-powered development assistance. 

## Working with This Repository

This project is designed to work with AI coding assistants. The repository includes AI-optimized documentation and integration tools:

### 🚀 **Quick Start with Claude Code**
1. Open this repository in Claude Code
2. Run `/OpenClone/StartStopScripts/Claude/start.bat` for shared development environment
3. Use the `cr` command anytime to have Claude analyze and update documentation

*AI Assistant documentation was created with Claude Code format.*

## Quick Start

Ready to create your first clone? Here's how:

### Option 1: Full Setup (Recommended)
1. **Download** - Clone this repository to your computer
2. **Configure** - Set up the environment variables below
3. **Database** - Run `StartStopScripts/Database/restore.bat` to set up database and OpenCloneFS
4. **Launch** - Run `StartStopScripts/run-all.bat` to start everything
5. **Create** - Visit `http://localhost:8080` and build your first clone!

### Option 2: Step-by-Step
Want to start individual services? Use these batch files:
- `StartStopScripts/Database/start.bat` - Start the database
- `StartStopScripts/SadTalker/start.bat` - Start video generation
- `StartStopScripts/U-2-Net/start.bat` - Start background removal
- `StartStopScripts/Website/start.bat` - Start the main website

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

- 🎯 **Quick Setup** - Get started with batch scripts
- 🔒 **Privacy First** - Your data stays on your computer
- 🎨 **Customizable** - Train your clone's personality and responses
- 📱 **Web Interface** - Works in any modern web browser
- 🚀 **GPU Accelerated** - Optimized for quick video creation
- 💾 **Export Options** - Download your clone videos and conversations

## Getting Help

- 📖 **Documentation** - Check the individual component README files for detailed setup
- 🐛 **Issues** - Found a bug? Create an issue in this repository
- 💡 **Questions** - Need help? Create an issue and we'll assist you


---

Ready to create your digital twin? Let's get started! 🚀

## Environment Variables

You'll need to configure several environment variables for OpenClone to work properly. See [Documentation/EnvironmentVariables.md](Documentation/EnvironmentVariables.md) for the complete list of required and optional settings.
