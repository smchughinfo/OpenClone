async function validateAndRun(formId, onValid) {
    var form = document.getElementById(formId)
    if (!form.checkValidity()) {
        form.classList.add('was-validated');
    }
    else {
        await onValid();
        resetForm(formId);
    }
}

function resetForm(formId) {
    document.getElementById(formId).classList.remove('was-validated');
}

function generateFormData(data) {
    const formData = new FormData();
    for (var prop in data) {
        var value = data[prop];
        if (value) {
            formData.append(prop, value);
        }
    }
    return formData;
}

export { validateAndRun, resetForm, generateFormData }