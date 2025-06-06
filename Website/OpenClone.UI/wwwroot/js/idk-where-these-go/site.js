// TODO: site.js and site.css shoudl be the only globally available css/js (aside from window.showerror and windowloader, etc. partial views). all other css/js should be loaded via import in each react page/component










// This needs to be renamed. It should be called signalr-error-handler.js or something

// This is from ChatGPT. It's so you don't have to write a catch for every single hub method call. They all get routed through here.



/*
class SignalRHelper {
    constructor(connection) {
        this.connection = connection;
    }

    async invoke(methodName, ...args) {
        try {
            const response = await this.connection.invoke(methodName, ...args);
            this.handleResponse(response);
        } catch (err) {
            console.log("ABCDEFG");
            globalError("Error in SignalR method " + methodName + ": " + err);
            // Additional error handling logic here
        }
    }

    handleResponse(response) {
        if (response && !response.Success) {
            // Handle the error response returned from the server
            globalError(response.ErrorMessage);

            if (response.DetailedError) {
                console.debug("Detailed error from server:", response.DetailedError);
            }
        } else {
            // Handle success if needed, e.g., return the response or call a callback
            return response;
        }
    }
}

// Strip # off of URL on all pages
window.history.replaceState(null, null, window.location.href.split('#')[0]);
*/