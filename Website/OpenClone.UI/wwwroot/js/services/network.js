function get(url) {
    return new Promise((resolve) => {
        var xhr = new XMLHttpRequest();
        xhr.open("GET", url, true);

        xhr.onload = () => { processResponse(xhr, resolve); }
        xhr.send();
    });
}

function post(url, data) {
    return new Promise((resolve) => {
        var xhr = new XMLHttpRequest();
        xhr.open("POST", url, true);

        if (data instanceof FormData) {
            // Let the browser set the Content-Type header for FormData
        } else {
            xhr.setRequestHeader("Content-Type", "application/json");
        }

        xhr.onload = () => { processResponse(xhr, resolve); }

        if (data instanceof FormData) {
            xhr.send(data);
        } else {
            xhr.send(JSON.stringify(data));
        }
    });
}

function processResponse(xhr, resolve) {
    if (xhr.status == 200 || xhr.status == 204) {
        try {
            if (xhr.responseText == "") {
                resolve("");
            }
            else {
                var response = JSON.parse(xhr.responseText);
                resolve(response);
            }
        }
        catch (e) {
            resolve(xhr.responseText);
        }
    }
    else {
        var json = JSON.parse(xhr.response);

        var openCloneErrorMessage = json.Detailed;
        var aspNetErrorMessage = json.title;
        if (openCloneErrorMessage) {
            window.showError(openCloneErrorMessage);
        }
        else if (aspNetErrorMessage) {
            console.error(aspNetErrorMessage);
        }
        else {
            // TODO: this should not be in prod, lol
            debugger;
        }
        throw (xhr);
    }
}

export { get, post }