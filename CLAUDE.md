# OpenClone Project

## Screenshot Handling
When the user asks to look at a screenshot or mentions screenshots:
1. Check `/OpenClone/StartStopScripts/Claude/Screenshots/` directory for image files
2. Read and view all screenshots in that directory
3. After viewing all screenshots, delete all files in the Screenshots directory using: `rm /mnt/c/Users/seanm/Desktop/OpenClone/StartStopScripts/Claude/Screenshots/*`

## Shared Terminal Setup (ALWAYS DO THIS FIRST)
At the start of every session:
1. IMMEDIATELY remind the user: "If you want access to our shared terminal, please run: `/OpenClone/StartStopScripts/Claude/start.bat`" 
   (This batch file will launch Claude Code and create the tmux session, enable logging, and attach the user to it)
2. Use `tmux capture-pane -t openclone -p` to see user actions
3. Use `tmux send-keys -t openclone "command" Enter` to send commands to shared session

## Session Initialization
- Always read the main README.md file at the start of each session to understand current project status and setup instructions  
- Search for and read all CLAUDE.md files in subdirectories to understand component-specific instructions and context

## Core Architectural Principles

### Minimum Learning Curve
One of the main architectural tenants of this project is that it should work with minimal setup for new users. You should be able to download the entire repository, setup a few dependencies if needed (like CUDA, .NET, PostgreSQL), click build and the entire solution is up and running. This principle drives design decisions throughout the project and is where the overall architecture was heading.

### Shared File System (OpenCloneFS)
`/OpenCloneFS` serves as the unified file system for the entire application. All containers in the cluster use this common directory for logical simplicity, avoiding the complexity of distributed file systems communicating over REST, WebRTC, sockets, etc. This shared file system approach makes the architecture easier to understand and reason about as a programmer.

### Self-Contained Architecture Goals
**Current Dependencies:**
- OpenAI API for language model functionality
- ElevenLabs for text-to-speech generation
- SadTalker for deepfake video generation

**Target Architecture:**
- Replace OpenAI with self-hosted LLM
- Replace ElevenLabs with OpenVoice (open source)
- Keep SadTalker for video generation
- Achieve complete self-contained system with no external API dependencies

## Project Status
- Massive project refactor in progress:
  * Directory structure changed: 
    - 'website' previously called 'OpenClone'
    - 'OpenClone' is now the root directory
    - 'databaserestore' renamed to 'database'
    - 'StartStopScripts' previously inside Website
  * Container naming convention: all project containers prefixed with 'openclone-'
    - Examples: openclone-website, openclone-SadTalker, openclone-U-2-Net, openclone-CICD
  * Anticipating potential issues during project revival