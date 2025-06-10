# OpenClone-DevContainer-StatusBar

## Overview
OpenClone-DevContainer-StatusBar is a VS Code extension that provides visual environment indication in the status bar when working with the OpenClone CICD application. It displays custom text and status bar color to clearly identify which development environment you're currently working in.

## Purpose
**Environment Awareness**: Prevents confusion when working across multiple development environments (local, remote, kind, vultr_dev, etc.) by providing prominent visual cues in the VS Code interface.

**CICD Integration**: Specifically designed for OpenClone CICD workflows where developers frequently switch between different deployment environments and need clear visual confirmation of their current context.

## Public Availability
- **Published Extension**: Available on VS Code Marketplace
- **Publisher**: opencloneai
- **Marketplace URL**: https://marketplace.visualstudio.com/items?itemName=opencloneai.openclone-devcontainer-statusbar
- **Intentionally OpenClone-Specific**: Effectively is general purpose but published as OpenClone-specific to avoid having to do maintenance if other people were to use it.

## Technical Implementation

### Minimal Logic Design
The extension is intentionally lightweight with minimal logic - it simply:
1. Reads configuration from `.vscode/settings.json`
2. Updates status bar text when configuration changes
3. Coordinates with VS Code's color customization system

### Configuration Integration
Monitors and responds to changes in `.vscode/settings.json`:

```json
{
  "opencloneDevContainerStatusBar.text": "my status bar text. e.g. vultr_dev",
  "workbench.colorCustomizations": {
    "statusBar.background": "#5A2500"
  }
}
```

### Core Functionality
- **Status Bar Item**: Creates left-aligned status bar widget with priority 100
- **Configuration Watching**: Automatically updates when `opencloneDevContainerStatusBar.text` changes
- **Real-time Updates**: No restart required when switching environments

## Code Structure

### Extension Entry Point (`extension.js`)
```javascript
// Creates status bar item
const statusBarItem = vscode.window.createStatusBarItem(
    vscode.StatusBarAlignment.Left, 100
);

// Updates text from configuration
const updateStatusBar = () => {
    const config = vscode.workspace.getConfiguration("opencloneDevContainerStatusBar");
    const text = config.get("text", "");
    statusBarItem.text = text;
};

// Listens for configuration changes
vscode.workspace.onDidChangeConfiguration((e) => {
    if (e.affectsConfiguration("opencloneDevContainerStatusBar.text")) {
        updateStatusBar();
    }
});
```

### Package Configuration (`package.json`)
- **Activation Events**: `onStartupFinished` and `onDidChangeConfiguration`
- **Configuration Schema**: Defines `opencloneDevContainerStatusBar.text` setting
- **VS Code Engine**: Requires VS Code ^1.95.0

## Use Cases

### Environment Identification
- **Local Development**: Shows "local" with neutral colors
- **Remote Development**: Shows "remote" with distinct background
- **Kubernetes (Kind)**: Shows "kind" with cluster-specific styling
- **Vultr Development**: Shows "vultr_dev" with cloud environment colors

### Visual Coordination
- **Text Indication**: Custom text in status bar
- **Color Coordination**: Works with `workbench.colorCustomizations` for status bar background
- **Theme Integration**: Coordinates with color theme selections

### Workflow Safety
- **Context Awareness**: Prevents deploying to wrong environment
- **Visual Confirmation**: Immediate feedback on current environment
- **Mistake Prevention**: Reduces risk of cross-environment configuration errors

## Development & Deployment

### Extension Development
```bash
# Generate extension scaffold
npm install -g yo generator-code
yo code

# Package for distribution
npm install -g vsce
vsce package

# Install locally
# Extensions > "..." > "Install from VSIX..."
```

### Configuration Schema
- **Setting Key**: `opencloneDevContainerStatusBar.text`
- **Type**: String
- **Default**: "OpenClone DevContainer StatusBar"
- **Description**: "Text to display in the status bar."

## File Structure
```
OpenClone-DevContainer-StatusBar/
├── extension.js              # Main extension logic
├── package.json              # Extension manifest and configuration
├── README.md                 # Development notes and setup instructions
├── CHANGELOG.md              # Version history
├── eslint.config.mjs         # Code linting configuration
├── jsconfig.json             # JavaScript project configuration
├── test/
│   └── extension.test.js     # Extension tests
└── vsc-extension-quickstart.md # VS Code extension development guide
```

## Design Philosophy
- **Single Purpose**: Does one thing well - environment indication
- **Minimal Complexity**: Simple configuration-driven updates
- **OpenClone-Specific**: Tailored for project needs without general-purpose bloat
- **Visual First**: Focuses on immediate visual feedback over complex features
- **Zero Maintenance**: Designed to "just work" without ongoing updates

## CICD Integration

### Shell Script Usage
The extension is actively used by the OpenClone CICD project through shell scripts located in `/CICD/scripts/status-bar.sh`:

**Helper Functions:**
```bash
# Update status bar text
set_statusbar_text() {
    jq --arg text "$1" '.["opencloneDevContainerStatusBar.text"] = $text' \
       /workspaces/CICD/.vscode/settings.json > tmp.json && mv tmp.json settings.json
}

# Update status bar color
set_statusbar_color() {
    jq --arg color "$1" '.["workbench.colorCustomizations"]["statusBar.background"] = $color' \
       /workspaces/CICD/.vscode/settings.json > tmp.json && mv tmp.json settings.json
}
```

**Usage Pattern (Pseudocode):**
```bash
# When switching to development environment
set_statusbar_text "vultr_dev"
set_statusbar_color "#5A2500"

# When switching to production environment  
set_statusbar_text "production"
set_statusbar_color "#FF0000"

# Extension automatically detects settings.json changes and updates VS Code status bar
```

## Integration Points
- **CICD Scripts**: Primary usage through `/CICD/scripts/status-bar.sh` automation
- **VS Code Settings**: Integrates with workspace-specific configuration via JSON manipulation
- **Environment Management**: Works alongside other environment identification tools
- **Developer Workflow**: Enhances safety and awareness during development