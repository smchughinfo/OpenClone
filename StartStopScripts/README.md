# StartStopScripts

![Server-0 Overview](/Documentation/startstopscripts.png)

Windows batch scripts for starting/stopping OpenClone development environment components.

## Usage

```bash
run-all.bat                   # Start all services
```

Individual components:
```bash
Database\start.bat           # PostgreSQL (port 5433)
SadTalker\start.bat         # AI video service (port 5001) 
U-2-Net\start.bat           # Image processing (port 5002)
OpenClone\start.bat         # Main website (port 8080)
LogViewer\start-local.bat   # Monitoring dashboard
WebPack\start.bat           # Frontend development server
```

Claude Code integration:
```bash
Claude\start.bat            # Shared terminals + screenshot capture
Claude\stop.bat             # Cleanup sessions
```

## Windows Terminal Themes

All scripts use branded Windows Terminal profiles for better visual organization. To get the themed terminals with custom colors and icons:

1. **Install Icon**: In `WindowsTerminal/OpenCloneTerminalSchemes.json` repoint `C:\\Users\\seanm\\Desktop\\OpenClone\\StartStopScripts\\WindowsTerminal\\terminal-icon.ico` to the location on your disk.
2. **Import Terminal Profiles**: Copy the contents of `WindowsTerminal/OpenCloneTerminalSchemes.json` into your Windows Terminal settings


Without these profiles, scripts will fall back to default terminal appearance but will still function normally.

## Requirements

- Windows with Docker Desktop
- OpenClone_ environment variables configured
- WSL2 for shared terminal functionality

## File Structure

```
StartStopScripts/
├── run-all.bat
├── Claude/                 # Claude Code integration tools
├── Database/               # PostgreSQL container scripts
├── Docker/                 # Docker Desktop management
├── LogViewer/              # Monitoring scripts (local/kind/remote)
├── OpenClone/              # Main application scripts
├── SadTalker/              # AI video generation scripts
├── U-2-Net/                # Image processing scripts
└── WebPack/                # Frontend development scripts
```

All containers use `openclone-*` naming convention. Scripts implement stop-then-start patterns for clean restarts.