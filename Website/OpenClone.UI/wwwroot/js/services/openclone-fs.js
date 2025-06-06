// TODO: YOU MIGHT WANT TO CALL THIS CLONEMETADATA SINCE IT MIRRORS THE SERVER SIDE CLONEMETADATA SERVICE
// TODO: IMPORTANT verify you cannot access another accoutns clones. the code that allows/disallows is in OpenCloneFSMiddleware

function getCloneImagePath(cloneId, noBackground) {
    if (noBackground) {
        return `OpenCloneFS/Clones/${cloneId}/clone-image-no-bg.png`;
    }
    else {
        return `OpenCloneFS/Clones/${cloneId}/clone-image-with-bg.png`;
    }
}

function getCloneAudioSamplePath(cloneId) {
    return `OpenCloneFS/Clones/${cloneId}/audio-sample.wav`;
}

function getCloneM3u8Path(cloneId) {
    return `OpenCloneFS/Clones/${cloneId}/DeepFake/Stream/stream.m3u8`;
}

function getCloneQuickFakePath(cloneId) {
    return `OpenCloneFS/Clones/${cloneId}/quick-fake.mp4`;
}

function getCloneTextToSpeakPath(cloneId) {
    return `OpenCloneFS/Clones/${cloneId}/DeepFake/text-to-speak.wav`;
}

export { getCloneImagePath, getCloneAudioSamplePath, getCloneM3u8Path, getCloneQuickFakePath, getCloneTextToSpeakPath }