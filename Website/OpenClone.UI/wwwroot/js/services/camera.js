function createCameraCapture(onCameraStart, onCameraStop, onPhotoCapture, onCameraAvailable, onError) {
    let stream = null;
    let isAvailable = false;

    // Check if camera is available
    const checkCameraAvailability = async () => {
        try {
            // Just check if we can get devices with video input
            const devices = await navigator.mediaDevices.enumerateDevices();
            const videoDevices = devices.filter(device => device.kind === 'videoinput');

            isAvailable = videoDevices.length > 0;

            if (onCameraAvailable) {
                onCameraAvailable(isAvailable, videoDevices);
            }

            return isAvailable;
        } catch (error) {
            if (onError) {
                onError(error);
            }
            isAvailable = false;
            if (onCameraAvailable) {
                onCameraAvailable(false);
            }
            return false;
        }
    };

    const startCamera = async (videoElement) => {
        try {
            // Check availability first
            await checkCameraAvailability();

            if (!isAvailable) {
                throw new Error("No camera available");
            }

            stream = await navigator.mediaDevices.getUserMedia({ video: true });
            videoElement.srcObject = stream;
            videoElement.play();
            if (onCameraStart) {
                onCameraStart(stream);
            }
        } catch (error) {
            if (onError) {
                onError(error);
            }
        }
    };

    const stopCamera = () => {
        if (stream) {
            stream.getTracks().forEach(track => track.stop());
            stream = null;
            if (onCameraStop) {
                onCameraStop();
            }
        }
    };

    const capturePhoto = (videoElement, canvasElement) => {
        if (!videoElement || !canvasElement) return;
        const context = canvasElement.getContext('2d');
        // Match canvas size to video
        canvasElement.width = videoElement.videoWidth;
        canvasElement.height = videoElement.videoHeight;
        // Draw the video frame to the canvas
        context.drawImage(videoElement, 0, 0, canvasElement.width, canvasElement.height);
        // Convert canvas to file
        canvasElement.toBlob((blob) => {
            const url = URL.createObjectURL(blob);
            const file = new File([blob], "webcam-capture.jpg", { type: "image/jpeg" });
            if (onPhotoCapture) {
                onPhotoCapture({ url, file });
            }
        }, 'image/jpeg', 0.95);
    };

    // Add this method to expose stream cleanup
    const getStream = () => stream;

    // Add method to check if camera is available
    const isCameraAvailable = () => isAvailable;

    return {
        startCamera,
        stopCamera,
        capturePhoto,
        getStream,
        checkCameraAvailability,
        isCameraAvailable
    };
}

const cleanupVideoStreams = (videoElement, cameraCapture) => {
    if (videoElement && videoElement.srcObject) {
        videoElement.srcObject.getTracks().forEach(track => track.stop());
        videoElement.srcObject = null;
    }
    // Clean up the internal stream if it exists using the cameraCapture instance
    if (cameraCapture && cameraCapture.getStream()) {
        const stream = cameraCapture.getStream();
        stream.getTracks().forEach(track => track.stop());
    }
};

export { createCameraCapture, cleanupVideoStreams };