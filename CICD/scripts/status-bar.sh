#!/bin/bash

set_statusbar_text() {
    local settings_file="/workspaces/CICD/.vscode/settings.json"
    local new_text="$1"
    if [ -f "$settings_file" ]; then
        # Use jq to update the JSON file
        jq --arg text "$new_text" '.["opencloneDevContainerStatusBar.text"] = $text' "$settings_file" > tmp.json && mv tmp.json "$settings_file"
        echo "Updated opencloneDevContainerStatusBar.text to '$new_text'."
    elif [ "$Server_0_CICD_ENV" != "server-0" ]; then
        echo "Error: settings.json not found at $settings_file."
    fi
}

set_statusbar_color() {
    echo "Server_0_CICD_ENV SSC---- $Server_0_CICD_ENV"
    local settings_file="/workspaces/CICD/.vscode/settings.json"
    local new_background="$1"
    if [ -f "$settings_file" ]; then
        # Use jq to update the JSON file
        jq --arg color "$new_background" '.["workbench.colorCustomizations"]["statusBar.background"] = $color' "$settings_file" > tmp.json && mv tmp.json "$settings_file"
        echo "Updated statusBar.background to '$new_background'."
    elif [ "$Server_0_CICD_ENV" != "server-0" ]; then
        echo "Error: settings.json not found at $settings_file."
    fi
}

# this function is effectively deprecated as the extension is now installed via the marketplace via devcontainer.json > customizations.vscode.extensions
install_statusbar() {
    local extension_name_substring="openclone-devcontainer-statusbar"
    local extension_url="https://github.com/smchughinfo/OpenClone-DevContainer-StatusBar/releases/download/V1/openclone-devcontainer-statusbar-0.0.1.vsix"
    local extension_filepath="/workspaces/CICD/openclone-devcontainer-statusbar.vsix"

    # if code is not in PATH or we already have the openclone-devcontainer-statusbar extension installed then exit
    if ! command -v code &> /dev/null || code --list-extensions | grep -q "$extension_name_substring"; then
        return 0
    fi

    # Download and install the extension
    echo "Downloading and installing $extension_name_substring..."
    curl -L -o "$extension_filepath" "$extension_url"
    code --install-extension "$extension_filepath"

    # Remove the downloaded file
    rm "$extension_filepath"
    echo "Installation of $extension_name_substring completed."
}

# allow functions in this script to be called from terminal
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    source /scripts/shell-helpers/function-runner.sh
fi