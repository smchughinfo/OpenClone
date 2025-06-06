import { get } from 'js/services/network.js';

class _OpenCloneSignalR {
    constructor() {
        this.connection = null;
    }

    async connect() {
        try {
            let jwToken = await get("/api/SignalR/GetJwtToken");

            this.connection = new signalR.HubConnectionBuilder()
                .withUrl("/chatHub", { accessTokenFactory: () => jwToken })
                .withAutomaticReconnect([0, 2000, 10000, 30000]) // Customize retry intervals: 0ms, 2s, 10s, 30s
                .build();

            this.connection.serverTimeoutInMilliseconds = 1000 * 60;

            await this.connection.start();
            console.log('SignalR Connected.');

            // Listen for error messages from the server
            this.connection.on("ReceiveError", (openCloneErrorMessage) => {
                window.showError(openCloneErrorMessage);
            });

            this.connection.onreconnecting((error) => {
                console.log('SignalR Connection lost. Reconnecting...', error);
            });

            this.connection.onreconnected((connectionId) => {
                console.log('SignalR Reconnected with connectionId: ' + connectionId);
            });

            this.connection.onclose((error) => {
                if (error) {
                    console.error('SignalR Connection closed with error:', error);
                } else {
                    console.log('SignalR Connection closed.');
                }
            });
        } catch (err) {
            console.error("SignalR Connection Error: ", err);
        }
    }
}

export default _OpenCloneSignalR;
