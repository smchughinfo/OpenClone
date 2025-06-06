import './QuickFake.css'

import chatHub from 'js/signalr/chat-hub.js';
import { getCloneQuickFakePath, getCloneTextToSpeakPath } from 'js/services/openclone-fs.js';
import { downloadAudioFile, getAudioFileLength, playAudioFile } from 'js/services/audio.js';

let chatSessionId = null;

const QuickFake = React.forwardRef((props, ref) => {
    const [readyState, setReadyState] = React.useState(false);

    const quickFakePath = getCloneQuickFakePath(props.cloneId);

    //////////////////////////////////////////////////////////////////
    ////////// INIT //////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////

    async function init() {
        await chatHub.connect();
        chatSessionId = await chatHub.getChatSessionId();
        setReadyState(true);
    }
    React.useEffect(() => init(), []);

    //////////////////////////////////////////////////////////////////
    ////////// LOGIC /////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////

    async function sendMessageToClone() {
        if (!props.messageToClone) {
            return;
        }
        await chatHub.sendMessageToCloneAndWaitForResponse(chatSessionId, props.messageToClone);
        PlayQuickFake()
    }

    async function PlayQuickFake() {
        var textToSpeakUrl = getCloneTextToSpeakPath(props.cloneId);
        const audio = await downloadAudioFile(textToSpeakUrl);

        const audioLengthInMs = await getAudioFileLength(audio);

        // Play the audio file when you want to
        var quickFakeVideo = document.getElementById("quickFakeVideo")
        playVideoForDuration(quickFakeVideo, audioLengthInMs);
        playAudioFile(audio);
    }

    function playVideoForDuration(videoElement, durationInMs) {
        // STEP 1: Set the video's time to 0 if it isn't already
        if (videoElement.currentTime !== 0) {
            videoElement.currentTime = 0;
        }

        // Calculate the video duration in milliseconds
        const videoDurationInMs = videoElement.duration * 1000;

        // Initialize remaining time to the requested duration
        let remainingTime = durationInMs;

        // Function to handle video play and looping
        function playAndLoopVideo() {
            if (remainingTime > 0) {
                videoElement.play();

                // Calculate time to next loop or stop
                const timeToNextAction = Math.min(remainingTime, videoDurationInMs);

                // Set a timeout to either loop or stop the video
                setTimeout(() => {
                    videoElement.pause();
                    remainingTime -= timeToNextAction;

                    // If there is remaining time, restart the video
                    if (remainingTime > 0) {
                        videoElement.currentTime = 0;
                        playAndLoopVideo();
                    }
                }, timeToNextAction);
            }
        }

        // Start the video playback and looping process
        playAndLoopVideo();
    }


    //////////////////////////////////////////////////////////////////
    ////////// PARENT/CHILD STATE SYNC ///////////////////////////////
    //////////////////////////////////////////////////////////////////

    React.useEffect(() => { props.onDeepFakePlayerReadyStateChange(readyState) }, [readyState])
    React.useImperativeHandle(ref, () => ({ handleClick: sendMessageToClone }));

    return (
        <div className="container-fluid">
            <video
                id="quickFakeVideo"
                src={quickFakePath}>
            </video>
        </div>
    );
});
export default QuickFake;
