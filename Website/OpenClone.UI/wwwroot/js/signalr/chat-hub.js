import _OpenCloneSignalR from 'js/signalr/_openclone-signalr.js';

class ChatHub extends _OpenCloneSignalR {
    constructor() {
        super();
    }

    getChatSessionId() {
        return this.connection.invoke("GetChatSessionId");
    }

    sendMessageToCloneAndWaitForResponse(chatSessionId, message) {
        return this.connection.invoke("MessageCloneAndWaitForResponse", chatSessionId, message);
    }
}

// Create an instance of ChatHub
const chatHub = new ChatHub();

export default chatHub;
