const vscode = require("vscode");

/**
 * @param {vscode.ExtensionContext} context
 */
function activate(context) {
    // Create a status bar item
    const statusBarItem = vscode.window.createStatusBarItem(
        vscode.StatusBarAlignment.Left,
        100
    );

    // Function to update the status bar
    const updateStatusBar = () => {
        const config = vscode.workspace.getConfiguration("opencloneDevContainerStatusBar");
        const text = config.get("text", "");
        statusBarItem.text = text;
    };

    // Initial setup
    updateStatusBar();
    statusBarItem.show();

    // Listen for configuration changes
    vscode.workspace.onDidChangeConfiguration((e) => {
        if (e.affectsConfiguration("opencloneDevContainerStatusBar.text")) {
            updateStatusBar();
        }
    });

    // Add the status bar item to the context's subscriptions
    context.subscriptions.push(statusBarItem);
}

function deactivate() {}

module.exports = {
    activate,
    deactivate
};
