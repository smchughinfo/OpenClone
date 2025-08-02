import './ChatBot.css';

import ThreePanes from '../../Components/Layouts/ThreePanes/ThreePanes';
import DeepFake from '../../Components/DeepFakePlayers/DeepFake/DeepFake';
import QuickFake from '../../Components/DeepFakePlayers/QuickFake/QuickFake';
import DeepFakeModeChooser from '../../Components/DeepFakeModeChooser/DeepFakeModeChooser';
import SystemMessageBuilder from '../../Components/SystemMessageBuilder/SystemMessageBuilder';
import { get, post } from 'js/services/network.js';

function ChatBot(props) {
    const [activeClone, setActiveClone] = React.useState(null);
    const [messageToClone, setMessageToClone] = React.useState();
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
            // Set cursor to wait while message is being processed
            document.body.style.cursor = 'wait';
            // Clear the textarea
            setMessageToClone("");
            deepFakePlayerRef.current.handleClick();
        }
    }

    async function onMessageFromClone() {
        // Reset cursor back to default
        document.body.style.cursor = 'default';
        // Refresh chat history with new messages
        await loadChatMessages();
    }

    return (
        <ThreePanes
            id="chatBot"
            left={
                <div style={{ display: 'flex', flexDirection: 'column', height: '100%', justifyContent: 'space-between' }}>
                    <div id="fakeWidget" style={{ flexShrink: 0 }}>
                        {deepFakeMode === 1 ? (
                            <QuickFake
                                ref={deepFakePlayerRef}
                                cloneId={activeClone ? activeClone.id : null}
                                messageToClone={messageToClone}
                                onDeepFakePlayerReadyStateChange={onDeepFakePlayerReadyStateChange}
                                onMessageFromClone={onMessageFromClone}
                            />
                        ) : deepFakeMode === 2 ? (
                            <DeepFake
                                ref={deepFakePlayerRef}
                                cloneId={activeClone ? activeClone.id : null}
                                messageToClone={messageToClone}
                                onDeepFakePlayerReadyStateChange={onDeepFakePlayerReadyStateChange}
                                onMessageFromClone={onMessageFromClone}
                            />
                        ) : null /* Handle other cases if necessary */}
                    </div>
                    
                    {activeClone && (
                        <div style={{ 
                            padding: '20px', 
                            backgroundColor: '#f8f9fa', 
                            borderRadius: '8px', 
                            border: '1px solid #dee2e6',
                            flex: 1,
                            display: 'flex',
                            flexDirection: 'column'
                        }}>
                            <h6 style={{ marginBottom: '15px', color: '#495057', borderBottom: '1px solid #dee2e6', paddingBottom: '8px' }}>Clone Profile</h6>
                            <div style={{ fontSize: '14px', lineHeight: '1.8', flex: 1, textAlign: 'left' }}>
                                <div style={{ display: 'flex', gap: '15px', marginBottom: '8px' }}>
                                    <div style={{ flex: 1 }}>
                                        <strong>Name:</strong> {activeClone.firstName}{activeClone.lastName ? ` ${activeClone.lastName}` : ''}
                                    </div>
                                    <div style={{ flex: 1 }}>
                                        <strong>Age:</strong> {activeClone.age || <em style={{ color: '#6c757d' }}>Not specified</em>}
                                    </div>
                                </div>
                                
                                <div style={{ display: 'flex', gap: '15px', marginBottom: '8px' }}>
                                    <div style={{ flex: 1 }}>
                                        <strong>Location:</strong> {
                                            activeClone.city && activeClone.state ? `${activeClone.city}, ${activeClone.state}` :
                                            activeClone.city ? activeClone.city :
                                            activeClone.state ? activeClone.state :
                                            <em style={{ color: '#6c757d' }}>Not specified</em>
                                        }
                                    </div>
                                    <div style={{ flex: 1 }}>
                                        <strong>Occupation:</strong> {activeClone.occupation || <em style={{ color: '#6c757d' }}>Not specified</em>}
                                    </div>
                                </div>
                                <div style={{ marginBottom: '8px' }}>
                                    <strong>Biography:</strong>
                                    <div style={{ 
                                        marginTop: '5px', 
                                        padding: '10px', 
                                        backgroundColor: 'white', 
                                        borderRadius: '4px', 
                                        border: '1px solid #e9ecef',
                                        minHeight: '60px',
                                        fontStyle: activeClone.biography ? 'normal' : 'italic',
                                        color: activeClone.biography ? 'inherit' : '#6c757d'
                                    }}>
                                        {activeClone.biography || 'No biography provided...'}
                                    </div>
                                </div>
                                
                                <div style={{ marginTop: 'auto', paddingTop: '15px', borderTop: '1px solid #dee2e6', fontSize: '12px', color: '#6c757d', display: 'flex', justifyContent: 'space-between' }}>
                                    <div>Created: {new Date(activeClone.createDate).toLocaleDateString()}</div>
                                    <div>Logging: {activeClone.allowLogging ? 'Enabled' : 'Disabled'}</div>
                                </div>
                            </div>
                        </div>
                    )}
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
                                onKeyDown={(e) => {
                                    if (e.key === 'Enter' && !e.shiftKey) {
                                        e.preventDefault();
                                        handleParentButtonClick();
                                    }
                                }}
                                rows="2"
                            />
                            <button 
                                type="button"
                                id="sendButton"
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
                <div style={{ display: 'flex', flexDirection: 'column', height: '100%', justifyContent: 'space-around' }}>
                    <div>
                        <h5>Settings</h5>
                    </div>
                    <hr />
                    <div>
                        <DeepFakeModeChooser
                            selectedMode={deepFakeMode}
                            onModeChange={setDeepFakeMode}
                            cloneId={activeClone ? activeClone.id : null}
                        />
                    </div>
                    <hr />
                    <div>
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
