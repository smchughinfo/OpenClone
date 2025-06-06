import './DeepFake.css';

import chatHub from 'js/signalr/chat-hub.js';
import { getCloneM3u8Path }  from 'js/services/openclone-fs.js';

let chatSessionId = null;

const DeepFake = React.forwardRef((props, ref) => {
    const [readyState, setReadyState] = React.useState(false);

    //////////////////////////////////////////////////////////////////
    ////////// INIT //////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////

    async function connect() {
        await chatHub.connect();
        chatSessionId = await chatHub.getChatSessionId();
        setReadyState(true);
    }
    React.useEffect(() => connect(), []);

    //////////////////////////////////////////////////////////////////
    ////////// LOGIC /////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////

    async function sendMessageToClone() {
        if (!props.messageToClone) {
            return;
        }
        await chatHub.sendMessageToCloneAndWaitForResponse(chatSessionId, props.messageToClone);
        var m3u8Url = getCloneM3u8Path(props.cloneId);
        var videoElement = document.getElementById("cloneStream");
        StreamM3u8(m3u8Url, videoElement);
    }

    function StreamM3u8(m3u8Url, videoElement) {
        if (Hls.isSupported()) {
            var hls = new Hls();
            hls.loadSource(m3u8Url);
            hls.attachMedia(videoElement);
            hls.on(Hls.Events.MANIFEST_PARSED, function () {
                videoElement.play();
            });
        }
    }

    //////////////////////////////////////////////////////////////////
    ////////// PARENT/CHILD STATE SYNC ///////////////////////////////
    //////////////////////////////////////////////////////////////////

    React.useEffect(() => { props.onDeepFakePlayerReadyStateChange(readyState) }, [readyState]);
    React.useImperativeHandle(ref, () => ({ handleClick: sendMessageToClone }));

    return (
        <div className="container-fluid">
            <video id="cloneStream"></video>
        </div>
    );
});
export default DeepFake;
