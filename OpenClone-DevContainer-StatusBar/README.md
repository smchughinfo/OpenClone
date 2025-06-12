# OpenClone-DevContainer-StatusBar - VS Code Extension

![Extension Overview](/Documentation/openclone-devcontainer-statusbar.png)

## What is this?

This is a VS Code extension that displays custom environment information in the status bar. It reads configuration from `.vscode/settings.json` to show text and coordinate with status bar color changes, providing visual confirmation of which development environment you're working in. The extension is designed for the OpenClone CICD workflow where developers switch between multiple deployment environments.

The extension is published on the VS Code Marketplace and integrates with shell scripts in the CICD project that automatically update the status bar when switching environments via `jq` commands that modify the settings file.

## Setup

1. Add VS Code color theme [unthrottled.doki-theme](https://marketplace.visualstudio.com/items?itemName=unthrottled.doki-theme)
2. Install from VS Code Marketplace: `opencloneai.openclone-devcontainer-statusbar`
3. Or install from VSIX: `npm install -g vsce`, `vsce package`, then install the generated `.vsix` file via Extensions > "..." > "Install from VSIX..."

## Development

Follow the VS Code extension development guide:
```bash
npm install -g yo generator-code
yo code
# Set "activationEvents": ["*"] in package.json
npm install -g vsce
vsce package
```

For more technical details and integration information, see [CLAUDE.md](CLAUDE.md).