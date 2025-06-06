// TODO: everywhere in the app where its called systemMessage it shuold be renamed to system prompt

import './SystemMessageBuilder.css';

import { get, post } from 'js/services/network.js';
import { setToolTips, updateToolTipTitles } from 'js/services/tooltip.js';
import { insertTextAtCursor } from 'js/services/cursor.js';

const HIGHLIGHT_CLASS = {
    red: "bg-danger",
    green: "bg-success",
    blue: "bg-primary",
    yellow: "bg-warning",
    white: "bg-secondary"
};

let loadingSystemMessage = "Loading...."; // necessary(?) evil temp variable to get everything loaded. Used as third null state (null, '', loadingSystemMessage)
let defaultSystemMessage = null;

function SystemMessageBuilder(props) {
    const [readyState, setReadyState] = React.useState(false);
    const [systemMessageData, setSystemMessageData] = React.useState([]);
    const [systemMessageRevert, setSystemMessageRevert] = React.useState('');
    const [systemMessage, setSystemMessage] = React.useState('');
    const [systemMessageHtml, setSystemMessageHtml] = React.useState('');
    const [editMode, setEditMode] = React.useState(false);
    const editPromptTextAreaRef = React.useRef(null); 

    //////////////////////////////////////////////////////////////////
    ////////// INIT //////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////

    async function init() {
        await loadSystemMessageData();
        await loadDefaultSystemMessage();
        await loadSystemMessage();
        
    }
    React.useEffect(() => init(), []);

    async function loadSystemMessageData() {
        var _systemMessageData = await get("/api/Chat/GetSystemMessageData");
        _systemMessageData = MapSystemMessageData(_systemMessageData);
        setSystemMessageData(_systemMessageData);
    }

    async function loadDefaultSystemMessage() {
        defaultSystemMessage = await get("/api/Chat/GetDefaultSystemMessage");
    }

    async function loadSystemMessage() {
        var _systemMessage = (await get("/api/CloneCRUD/GetActiveClone")).systemMessage;
        _systemMessage = _systemMessage ? _systemMessage : loadingSystemMessage;
        setSystemMessage(_systemMessage);
        setSystemMessageRevert(_systemMessage);
    }
    
    //////////////////////////////////////////////////////////////////
    // COMPLICATED LOAD COMPLETE / DEFAULT SYSTEM MESSAGE LOGIC //////
    //////////////////////////////////////////////////////////////////

    const systemMessageLoaded = React.useRef(false);
    React.useEffect(() => { systemMessageLoaded.current = systemMessage ? true : false; }, [systemMessage]);

    const systemMessageDataLoaded = React.useRef(false);
    React.useEffect(() => { systemMessageDataLoaded.current = systemMessageData.length > 0 }, [systemMessageData]);

    function resetSystemMessageLoadedFlags() {
        systemMessageLoaded.current = false;
        systemMessageDataLoaded.current = false;
    }

    function onLoadComplete() {
        var loadComplete = systemMessageLoaded.current && systemMessageDataLoaded.current;
        if (loadComplete) {
            var _systemMessage = (systemMessage && systemMessage != loadingSystemMessage) ? systemMessage : defaultSystemMessage;
            setSystemMessage(_systemMessage);
        }
        if (loadComplete && readyState == false) {
            setReadyState(true);
        }
    }
    React.useEffect(() => onLoadComplete(), [systemMessage, systemMessageData]);

    //////////////////////////////////////////////////////////////////
    ////////// SYSTEM MESSAGE DATA ///////////////////////////////////
    //////////////////////////////////////////////////////////////////

    React.useEffect(() => updateToolTipTitles(), [systemMessageData]); // if a message data wasn't in the system prompt and now it is or vice versa 
   
    function MapSystemMessageData(_systemMessageData) {
        var mappedData = [];
        _systemMessageData.forEach(data => {
            const textToHighlight = `{${data.key}}`;
            const includedInSystemMessage = systemMessage.indexOf(textToHighlight) !== -1;
            mappedData.push({
                ...data,
                textToHighlight: textToHighlight,
                description: getDescription(data),
                includedInSystemMessage: includedInSystemMessage,
                highlightStyle: getHighlightStyle(data.populated, includedInSystemMessage)
            });
        });
        return mappedData;
    }

    function getDescription(data) {
        if (data.category == "CloneAnswers") {
            return data.populated ? `Placeholder for answers to most related Q/A. This clone has ${data.value} answers to draw from.` : "No Questions Answered";
        }
        else {
            return data.populated ? data.value : "No Value Entered";
        }
    }

    function getHighlightStyle(populated, inSystemMessage) {
        if (populated) {
            if (inSystemMessage) {
                return HIGHLIGHT_CLASS.green;
            }
            else {
                return HIGHLIGHT_CLASS.yellow;
            }
        }
        else {
            if (inSystemMessage) {
                return HIGHLIGHT_CLASS.red;
            }
            else {
                return HIGHLIGHT_CLASS.white;
            }
        }
    }

    //////////////////////////////////////////////////////////////////
    ////////// MESSAGE UPDATE CHAIN //////////////////////////////////
    //////////////////////////////////////////////////////////////////

    // CHAIN LINK 1 (SystemMessage->SystemMessageData)
    function updateSystemMessageData() {
        var _systemMessageData = systemMessageData.map(d => {
            var includedInSystemMessage = systemMessage && (systemMessage.indexOf(d.textToHighlight) !== -1);
            var highlightStyle = getHighlightStyle(d.populated, includedInSystemMessage);
            return {
                ...d,
                highlightStyle: highlightStyle,
                includedInSystemMessage: includedInSystemMessage
            };
        });
        setSystemMessageData(_systemMessageData);
    }
    React.useEffect(() => { updateSystemMessageData(); }, [systemMessage]);

    // CHAIN LINK 2 (SystemMessageData->PrompPrefixHtml)
    function updateSystemMessageHtml() {
        let _systemMessageHtml = systemMessage ? systemMessage : ""; // start with normal prompt prefix text and then add html/styles to it
        _systemMessageHtml = _systemMessageHtml.replace(/\n/g, "<br/>");
        systemMessageData.forEach(d => {
            _systemMessageHtml = _systemMessageHtml.replace(d.textToHighlight, `<span class="badge rounded-pill ${d.highlightStyle}" data-bs-toggle="tooltip" title="${d.description}">${d.key}</span>`);
        });
        setSystemMessageHtml(_systemMessageHtml);
    }
    React.useEffect(() => { updateSystemMessageHtml(); }, [systemMessageData]);

    // CHAIN LINK 3 (PrompPrefixHtml->Do the tooltips)
    React.useEffect(() => { updateToolTipTitles(); }, [systemMessageHtml]);

    //////////////////////////////////////////////////////////////////
    ////////// SAVE / EDIT ////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////

    function clearFocusOnEditModeChange() {
        var focusedButton = document.querySelector("button:focus");
        if (focusedButton) {
            focusedButton.blur();
        }
    }
    React.useEffect(() => { clearFocusOnEditModeChange(); }, [editMode]);


    async function saveSystemMessage(text) {
        window.showLoader(window.loader.SAVING_MESSAGE, true);
        resetSystemMessageLoadedFlags();
        await post("/api/Chat/UpdateSystemMessage", text);
        await loadSystemMessage();
        window.hideLoader();
        setEditMode(false);
        setTimeout(updateToolTipTitles, 1000); // change in edit mode -> (trigger systemmessage and systemmessagehtml update + updatetooltip but tooltip is displaynone in editmode so it doesnt work) -> call server do update get value back -> no trigger systemmessage change cause server returns value we just gave it -> chain link sequence never runs -> tooltips remain unset. -- this is one line fix that should almost always work. spent 15 minutes thinking about this - too much time already
    }

    function cancelEditMode() {
        setEditMode(false);
        setSystemMessage(systemMessageRevert);
    }

    //////////////////////////////////////////////////////////////////
    ////////// PARENT/CHILD STATE SYNC ///////////////////////////////
    //////////////////////////////////////////////////////////////////

    React.useEffect(() => { props.onReadyStateChange(readyState); }, [readyState]);

    return (
        <div className="prompt-prefix-builder">
            {editMode ? (
                <div className="prompt-prefix-editor">
                    <textarea
                        className="form-control"
                        value={systemMessage}
                        onChange={e => { setSystemMessage(e.target.value); } }
                        ref={editPromptTextAreaRef}
                    ></textarea>
                    <div className="button-carrier">
                        <button type="button" className="btn btn-danger btn-sm" onClick={cancelEditMode}>
                            <i className="bi bi-x-lg"></i>
                        </button>
                        <button type="button" className="btn btn-primary btn-sm ms-1" onClick={() => { saveSystemMessage(systemMessage); } }>
                            <i className="bi bi-floppy"></i>
                        </button>
                    </div>
                </div>
            ) : (
                <div className="prompt-prefix-viewer">
                    <div
                        id={props.cloneId}
                        dangerouslySetInnerHTML={{ __html: systemMessageHtml }}
                        ></div>
                    <div className="button-carrier">
                            <button type="button" className="btn btn-primary btn-sm" onClick={() => { saveSystemMessage(null); }}>
                            <i className="bi bi-arrow-clockwise"></i>
                        </button>
                            <button type="button" className="btn btn-primary btn-sm ms-1" onClick={() => { setEditMode(true);  }}>
                            <i className="bi bi-pencil"></i>
                        </button>
                    </div>
                </div>
            )}
            <div className="highlight-buttons">
                {systemMessageData.map((d, i) => {
                    return (
                        <span
                            key={i}
                            className={`badge rounded-pill-placeholder ${d.highlightStyle}`}
                            data-bs-toggle="tooltip"
                            title={(d.highlightStyle === HIGHLIGHT_CLASS.yellow ? "Value provided but not used: " : "") + d.description}
                            onClick={() => { if(editMode) setSystemMessage(insertTextAtCursor(editPromptTextAreaRef.current, d.key)); }}
                        >
                            {d.key}
                        </span>
                    );
                })}
            </div>
        </div>
    );
}

export default SystemMessageBuilder;