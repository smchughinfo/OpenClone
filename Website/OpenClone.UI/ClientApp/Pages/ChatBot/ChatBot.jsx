import './ChatBot.css';

import ThreePanes from '../../Components/Layouts/ThreePanes/ThreePanes';
import DeepFake from '../../Components/DeepFakePlayers/DeepFake/DeepFake';
import QuickFake from '../../Components/DeepFakePlayers/QuickFake/QuickFake';
import DeepFakeModeChooser from '../../Components/DeepFakeModeChooser/DeepFakeModeChooser';
import SystemMessageBuilder from '../../Components/SystemMessageBuilder/SystemMessageBuilder';
import { get, post } from 'js/services/network.js';

function ChatBot(props) {
    const [activeClone, setActiveClone] = React.useState(null);
    const [messageToClone, setMessageToClone] = React.useState("hi, do you prefer red or blue (pick one)");
    const [deepFakeMode, setDeepFakeMode] = React.useState(null);
    const [deepFakePlayerReadyState, setDeepFakePlayerReadyState] = React.useState(false);
    const deepFakePlayerRef = React.useRef();
    const [systemMessageBuilderReadyState, setSystemMessageBuilderReadyState] = React.useState(false);
    const [chatMessages, setChatMessages] = React.useState([]);
    const chatContainerRef = React.useRef();

    //////////////////////////////////////////////////////////////////
    ////////// PAGE INIT /////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////

    async function init() {
        window.showLoader();
        await loadClone();
        await loadChatMessages();
    }
    React.useEffect(() => init(), []);

    async function loadClone() {
        var _activeClone = await get("/api/CloneCRUD/GetActiveClone");
        setActiveClone(_activeClone);
        setDeepFakeMode(_activeClone.deepFakeMode.id);
    }

    async function loadChatMessages() {
        try {
            var messages = await get("/api/Chat/GetChatSessionMessages");
            setChatMessages(messages || []);
        } catch (error) {
            console.error("Error loading chat messages:", error);
            setChatMessages([]);
        }
    }

    async function onChildComponentLoaded() {
        if (deepFakePlayerReadyState && systemMessageBuilderReadyState) {
            window.hideLoader();
        }
    }
    React.useEffect(() => onChildComponentLoaded(), [deepFakePlayerReadyState, systemMessageBuilderReadyState]);

    // Auto-scroll to bottom when messages change
    function scrollToBottom() {
        if (chatContainerRef.current) {
            chatContainerRef.current.scrollTop = chatContainerRef.current.scrollHeight;
        }
    }
    React.useEffect(() => scrollToBottom(), [chatMessages]);

    // Format timestamp for display
    function formatTimestamp(timestamp) {
        const date = new Date(timestamp);
        return date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
    }

    //////////////////////////////////////////////////////////////////
    ////////// PARENT/CHILD STATE SYNC ///////////////////////////////
    //////////////////////////////////////////////////////////////////

    function onDeepFakePlayerReadyStateChange(readyState) {
        setDeepFakePlayerReadyState(readyState);
    }

    function onSystemMessageBuilderReadyStateChange(readyState) {
        setSystemMessageBuilderReadyState(readyState)
    }

    function handleParentButtonClick() {
        if (deepFakePlayerRef.current) {
            deepFakePlayerRef.current.handleClick();
        }
    }

    return (
        <ThreePanes
            id="chatBot"
            left={
                <div>
                    {deepFakeMode === 1 ? (
                        <QuickFake
                            ref={deepFakePlayerRef}
                            cloneId={activeClone ? activeClone.id : null}
                            messageToClone={messageToClone}
                            onDeepFakePlayerReadyStateChange={onDeepFakePlayerReadyStateChange}
                        />
                    ) : deepFakeMode === 2 ? (
                        <DeepFake
                            ref={deepFakePlayerRef}
                            cloneId={activeClone ? activeClone.id : null}
                            messageToClone={messageToClone}
                            onDeepFakePlayerReadyStateChange={onDeepFakePlayerReadyStateChange}
                        />
                    ) : null /* Handle other cases if necessary */}
                </div>
            }
            center={
                <div className="chat-interface">
                    <div 
                        className="chat-messages-container" 
                        ref={chatContainerRef}
                    >
                        {chatMessages.length === 0 ? (
                            <div className="empty-chat">
                                <p className="text-muted">Start a conversation with your clone!</p>
                            </div>
                        ) : (
                            chatMessages.map((message, index) => (
                                <div 
                                    key={message.id || index} 
                                    className={`message ${message.chatRole.enumName.toLowerCase()}`}
                                >
                                    <div className="message-content">
                                        <div className="message-text">
                                            {message.message}
                                        </div>
                                        <div className="message-time">
                                            {formatTimestamp(message.timeStamp)}
                                        </div>
                                    </div>
                                </div>
                            ))
                        )}
                    </div>
                    <div className="chat-input-container">
                        <div className="input-group">
                            <textarea
                                id="messageInput"
                                className="form-control"
                                placeholder="Type your message..."
                                value={messageToClone}
                                onChange={(e) => { setMessageToClone(e.target.value); }}
                                rows="2"
                            />
                            <button 
                                type="button" 
                                className="btn btn-primary" 
                                onClick={handleParentButtonClick}
                            >
                                <i className="bi bi-send"></i>
                            </button>
                        </div>
                    </div>
                </div>
            }
            right={
                <div>
                    <h5>Settings</h5>
                    <DeepFakeModeChooser
                        selectedMode={deepFakeMode}
                        onModeChange={setDeepFakeMode}
                        cloneId={activeClone ? activeClone.id : null}
                    />
                    <div style={{ marginTop: '20px' }}>
                        <SystemMessageBuilder
                            cloneId={activeClone ? activeClone.id : null}
                            onReadyStateChange={onSystemMessageBuilderReadyStateChange}
                        >
                        </SystemMessageBuilder>
                    </div>
                </div>
            }
        />
    );
}

ReactDOM.render(<ChatBot />, document.getElementById("root"));
