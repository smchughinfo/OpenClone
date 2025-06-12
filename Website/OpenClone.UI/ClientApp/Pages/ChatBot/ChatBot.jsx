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

    //////////////////////////////////////////////////////////////////
    ////////// PAGE INIT /////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////

    async function init() {
        window.showLoader();
        await loadClone();
    }
    React.useEffect(() => init(), []);

    async function loadClone() {
        var _activeClone = await get("/api/CloneCRUD/GetActiveClone");
        setActiveClone(_activeClone);
        setDeepFakeMode(_activeClone.deepFakeMode.id);
    }

    async function onChildComponentLoaded() {
        if (deepFakePlayerReadyState && systemMessageBuilderReadyState) {
            window.hideLoader();
        }
    }
    React.useEffect(() => onChildComponentLoaded(), [deepFakePlayerReadyState, systemMessageBuilderReadyState]);

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
                <>
                    <DeepFakeModeChooser
                        selectedMode={deepFakeMode}
                        onModeChange={setDeepFakeMode}
                        cloneId={activeClone ? activeClone.id : null}
                    />
                    <SystemMessageBuilder
                        cloneId={activeClone ? activeClone.id : null}
                        onReadyStateChange={onSystemMessageBuilderReadyStateChange}
                    >
                        
                    </SystemMessageBuilder>
                </>
            }
            center={
                <div>
                    <div className="row">
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
                    <div className="row">
                        <div className="col-10">
                            <textarea
                                id="messageInput"
                                className="form-control"
                                value={messageToClone}
                                onChange={(e) => { setMessageToClone(e.target.value); }}
                            >
                            </textarea>
                        </div>
                        <div className="col-2">
                            <button type="button" className="btn btn-primary w-100" onClick={handleParentButtonClick}>
                                <i className="bi bi-floppy"></i>
                            </button>
                        </div>
                    </div>
                </div>
            }
            right={
                <div>
                    {/* THING 3
                    <hr />
                    <span>
                        {activeClone ? activeClone.id + " <-activeClone.id" : "NO ACTIVECLONEID"}
                    </span> */}
                </div>
            }
        />
    );
}

ReactDOM.render(<ChatBot />, document.getElementById("root"));
