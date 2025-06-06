/*function setToolTips(scope) {
    const tooltipTriggerList = document.querySelectorAll(scope ? scope : '[data-bs-toggle="tooltip"]');
    const tooltipList = [...tooltipTriggerList].map(tooltipTriggerEl => new bootstrap.Tooltip(tooltipTriggerEl));
}*/

function setToolTips(scope) {
    const tooltipTriggerList = document.querySelectorAll(scope ? scope : '[data-bs-toggle="tooltip"]');

    tooltipTriggerList.forEach(tooltipTriggerEl => {
        // Check if tooltip is already initialized
        if (!tooltipTriggerEl.getAttribute('data-bs-original-title')) {
            // Initialize new tooltip if not already set
            new bootstrap.Tooltip(tooltipTriggerEl);
        }
    });
}

function updateToolTipTitles(scope) {
    const tooltipTriggerList = document.querySelectorAll(scope ? scope : '[data-bs-toggle="tooltip"]');
    const tooltipList = [...tooltipTriggerList].forEach(tooltipTriggerEl => {
        var title = tooltipTriggerEl.getAttribute("title");
        if (!title) {
            var originalTitle = tooltipTriggerEl.getAttribute("data-bs-original-title");
            tooltipTriggerEl.setAttribute("title", originalTitle);
        }
        tooltipTriggerEl.removeAttribute("data-bs-original-title");

        var tooltipInstance = bootstrap.Tooltip.getInstance(tooltipTriggerEl); // Get the tooltip instance
        if (tooltipInstance) {
            tooltipInstance.dispose(); // Dispose of the tooltip to hide it
        }
    });

    setToolTips(scope);
}

export { setToolTips, updateToolTipTitles }