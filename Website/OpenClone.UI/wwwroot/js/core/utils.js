function globalError(ex) {
    alert("Global Error");
    console.error(ex);
}

function streamM3u8(m3u8Url, videoElement) {
    if (Hls.isSupported()) {
        var hls = new Hls();
        hls.loadSource(m3u8Url);
        hls.attachMedia(videoElement);
        hls.on(Hls.Events.MANIFEST_PARSED, function () {
            videoElement.play();
        });
    }
    // HLS.js is not supported on platforms that do not have Media Source Extensions (MSE) enabled.
    // When the browser has built-in HLS support (check using `canPlayType`), we can provide an HLS manifest (i.e. .m3u8 URL) directly to the video element through the `src` attribute.
    else if (videoElement.canPlayType('application/vnd.apple.mpegurl')) {
        videoElement.src = m3u8Url;
        videoElement.addEventListener('loadedmetadata', function () {
            videoElement.play();
        });
    }
}

function formatDateTime(date) {
    let d = new Date(date);

    let month = (d.getMonth() + 1).toString().padStart(2, '0');
    let day = d.getDate().toString().padStart(2, '0');
    let year = d.getFullYear();

    let hours = d.getHours();
    let minutes = d.getMinutes().toString().padStart(2, '0');

    let ampm = hours >= 12 ? 'PM' : 'AM';
    hours = hours % 12;
    hours = hours ? hours : 12; // the hour '0' should be '12'
    let strTime = hours + ':' + minutes + ' ' + ampm;

    return month + '/' + day + '/' + year + ' ' + strTime;
}


export { globalError, streamM3u8, formatDateTime }