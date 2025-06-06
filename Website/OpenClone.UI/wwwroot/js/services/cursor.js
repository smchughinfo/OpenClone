$("head").append("<style> .show-loader { cursor: progress !important }</style>"); // TODO: do a better loader
function turnCursorToSpinner() {
    $("*").addClass("show-loader");
}

function resetCursor() {
    $("*").removeClass("show-loader");
}

function insertTextAtCursor(element, text) {
    text = `{${text}}`;

    let newMessage = "";
    if (element) {
        const start = element.selectionStart;
        const end = element.selectionEnd;

        // Update the systemMessage state by inserting the new text
        newMessage = element.textContent.slice(0, start) + text + element.textContent.slice(end);

        // Set the cursor position after the inserted text
        setTimeout(() => {
            element.selectionStart = element.selectionEnd = start + text.length;
            element.focus();
        }, 0);
    }

    return newMessage;
}

export { turnCursorToSpinner, resetCursor, insertTextAtCursor }