async function downloadAudioFile(url) {
    // STEP 1: Download the .wav file from the server
    const response = await fetch(url);
    if (!response.ok) {
        throw new Error(`Failed to download audio file: ${response.statusText}`);
    }

    const arrayBuffer = await response.arrayBuffer();
    const audioBlob = new Blob([arrayBuffer], { type: 'audio/wav' });

    // Convert Blob to an object URL
    const audioUrl = URL.createObjectURL(audioBlob);

    // Create an Audio object
    const audio = new Audio(audioUrl);

    // Return the audio object
    return audio;
}

function getAudioFileLength(audio) {
    // STEP 2: Return the length of the audio file in milliseconds
    return new Promise((resolve, reject) => {
        audio.onloadedmetadata = () => {
            const duration = audio.duration * 1000; // duration in milliseconds
            resolve(duration);
        };

        audio.onerror = () => {
            reject(new Error('Failed to load audio metadata.'));
        };
    });
}

function playAudioFile(audio) {
    // STEP 3: Play the audio file
    audio.play().catch((error) => {
        console.error('Failed to play audio:', error);
    });
}

function createAudioRecorder(callbacks) {
    const {
        onRecordingStart,
        onRecordingStop,
        onAudioAvailable,
        onAudioChunk,
        onError
    } = callbacks;

    let audioRecorder = null;
    let audioChunks = [];

    // Start recording audio from the microphone
    const startRecording = () => {
        navigator.mediaDevices.getUserMedia({ audio: true })
            .then(stream => {
                audioRecorder = new MediaRecorder(stream);

                // Reset chunks at beginning of new recording
                audioChunks = [];

                // Handle data as it becomes available during recording
                audioRecorder.ondataavailable = e => {
                    audioChunks.push(e.data);
                    if (onAudioChunk) onAudioChunk(audioChunks);
                };

                // Handle end of recording
                audioRecorder.onstop = () => {
                    // Create audio blob and URL for it
                    const audioBlob = new Blob(audioChunks, { type: 'audio/wav' });
                    const audioUrl = URL.createObjectURL(audioBlob);

                    // Create a File object from the Blob for form submission
                    const audioFile = new File([audioBlob], "recorded-audio.wav", {
                        type: 'audio/wav',
                        lastModified: new Date().getTime()
                    });

                    // Provide the audio data via callback
                    if (onAudioAvailable) {
                        onAudioAvailable({
                            blob: audioBlob,
                            url: audioUrl,
                            file: audioFile
                        });
                    }

                    // Clean up stream
                    stream.getTracks().forEach(track => track.stop());
                };

                // Start the recording
                audioRecorder.start();
                if (onRecordingStart) onRecordingStart(audioRecorder);
            })
            .catch(error => {
                console.error("Error accessing microphone:", error);
                if (onError) {
                    onError(error);
                } else {
                    alert("Unable to access your microphone. Please check your browser permissions.");
                }
            });
    };

    // Stop the current recording
    const stopRecording = () => {
        if (audioRecorder && audioRecorder.state !== 'inactive') {
            audioRecorder.stop();
            if (onRecordingStop) onRecordingStop();
        }
    };

    // Return functions to control recording
    return {
        startRecording,
        stopRecording
    };
}

function cleanupAudioStreams(mediaRecorder) {
    if (mediaRecorder && mediaRecorder.stream) {
        mediaRecorder.stream.getTracks().forEach(track => track.stop());
    }
}

export { downloadAudioFile, getAudioFileLength, playAudioFile, createAudioRecorder, cleanupAudioStreams }