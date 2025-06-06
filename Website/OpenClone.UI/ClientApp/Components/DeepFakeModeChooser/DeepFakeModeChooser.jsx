import './DeepFakeModeChooser.css';

import { setToolTips } from 'js/services/tooltip.js';
import { get, post } from 'js/services/network.js';

const deepFakeModes = [
    { id: 1, title: "QuickFake", description: "Uses a pregenerated deepfake video (audio is not synced). This mode is fast and cheap." },
    { id: 2, title: "DeepFake", description: "Generates a deepfake video every time the clone speaks. This mode is slow and more expensive." }
];

function DeepFakeModeChooser(props) {
    const [localSelectedMode, setLocalSelectedMode] = React.useState(props.selectedMode || deepFakeModes[0].id);

    //////////////////////////////////////////////////////////////////
    ////////// COMPONENT INIT ////////////////////////////////////////
    //////////////////////////////////////////////////////////////////

    async function init() {
        setToolTips('#deepfake-mode-chooser [data-bs-toggle="tooltip"]');
    }
    React.useEffect(() => init(), []);

    //////////////////////////////////////////////////////////////////
    ////////// PARENT/CHILD STATE SYNC ///////////////////////////////
    //////////////////////////////////////////////////////////////////

    React.useEffect(() => {
        setLocalSelectedMode(props.selectedMode);
    }, [props.selectedMode]);

    //////////////////////////////////////////////////////////////////
    ////////// EVENT HANDLERS ////////////////////////////////////////
    //////////////////////////////////////////////////////////////////

    async function handleModeChange(e) {
        const modeId = parseInt(e.target.id.replace('btnradio', ''), 10);
        setLocalSelectedMode(modeId);

        if (props.onModeChange) {
            props.onModeChange(modeId);
        }
        if (props.cloneId) {
            window.showLoader(window.loader.UPDATING_MESSAGE);
            await post("/api/CloneMetaData/SetDeepFakeMode", modeId);
            window.hideLoader();
        }
    }

    return (
        <div id="deepfake-mode-chooser">
            <label className="form-label">DeepFake Mode</label>
            <div className="btn-group deepfake-mode-buttons" role="group" aria-label="Basic radio toggle button group">
                {deepFakeModes.map(mode => (
                    <React.Fragment key={mode.id}>
                        <input
                            type="radio"
                            className="btn-check"
                            name="btnradio"
                            id={`btnradio${mode.id}`}
                            autoComplete="off"
                            checked={localSelectedMode === mode.id}
                            onChange={e => { handleModeChange(e); }}
                        />
                        <label className="btn btn-outline-primary" htmlFor={`btnradio${mode.id}`} data-bs-toggle="tooltip" title={mode.description} >
                            {mode.title}
                        </label>
                    </React.Fragment>
                ))}
            </div>
        </div>
    );
}

export default DeepFakeModeChooser;
