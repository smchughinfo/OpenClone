import './CloneCRUD.css';
import { get, post } from 'js/services/network.js';
import { createAudioRecorder, cleanupAudioStreams } from 'js/services/audio.js';
import { createCameraCapture, cleanupVideoStreams } from 'js/services/camera.js';
import { logError } from 'js/services/error.js';
import { validateAndRun, resetForm, generateFormData } from 'js/services/form-utilities.js';
import { getCloneImagePath, getCloneAudioSamplePath } from 'js/services/openclone-fs.js';
import { setToolTips } from 'js/services/tooltip.js';
import { showConfirmDialog } from '../../Components/ConfirmDialog/ConfirmDialog';
import DeepFakeModeChooser from '../../Components/DeepFakeModeChooser/DeepFakeModeChooser';

const newCloneId = -1;
const blankCloneImagePath = "/images/site/person-bounding-box.svg";
const cloneFormId = "cloneForm";

function CloneCRUD(props) {
    const [activeClone, setActiveClone] = React.useState(null);
    const [userClones, setUserClones] = React.useState([]);
    const [cloneImage, setCloneImage] = React.useState(blankCloneImagePath);
    const [cloneImageFile, setCloneImageFile] = React.useState(null);
    const [cloneAudio, setCloneAudio] = React.useState(null);
    const [cloneAudioFile, setCloneAudioFile] = React.useState(null);
    const audioRef = React.useRef(null);
    const [firstName, setFirstName] = React.useState("");
    const [lastName, setLastName] = React.useState("");
    const [nickName, setNickName] = React.useState("");
    const [age, setAge] = React.useState("");
    const [biography, setBiography] = React.useState("");
    const [city, setCity] = React.useState("");
    const [state, setState] = React.useState("");
    const [occupation, setOccupation] = React.useState("");
    const [makePublic, setMakePublic] = React.useState(false);
    const [allowLogging, setAllowLogging] = React.useState(false);
    const [deepfakeMode, setDeepFakeMode] = React.useState(null);
    const [isRecording, setIsRecording] = React.useState(false);
    const [audioRecorder, setAudioRecorder] = React.useState(null);
    const [recordedAudio, setRecordedAudio] = React.useState(null);
    const [audioChunks, setAudioChunks] = React.useState([]);
    const [isCapturingPhoto, setIsCapturingPhoto] = React.useState(false);
    const [videoRef, setVideoRef] = React.useState(React.createRef());
    const [canvasRef, setCanvasRef] = React.useState(React.createRef());

    //////////////////////////////////////////////////////////////////
    ////////// PAGE INIT /////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////

    async function init() {
        setToolTips();
        await loadClones();
    }

    async function init() {
        setToolTips();
        await loadClones();
    }
    React.useEffect(() => init(), []);

    async function loadClones() {
        window.showLoader();

        // get all the clones for this user
        var _userClones = await get("/api/CloneCRUD/GetClones");
        setUserClones(_userClones);
        window.hideLoader();
    }

    async function useActiveClone() {
        window.showLoader();
        // get the active clone.
        if (userClones.length > 0) {
            var activeCloneId = await get("/api/ApplicationUser/GetActiveCloneId");
            var _activeClone = userClones.find(clone => clone.id == activeCloneId);
            setActiveClone(_activeClone);
        }
        else {
            setActiveClone();
        }

        window.hideLoader();
    }
    React.useEffect(() => useActiveClone(), [userClones]);

    function handleActiveCloneChanged() {
        resetForm(cloneFormId);

        if (activeClone == null) {
            setCloneImage(blankCloneImagePath);
            setCloneImageFile(null);
            setCloneAudio("");
            setCloneAudioFile(null);
            setFirstName("");
            setLastName("");
            setNickName("");
            setAge("");
            setBiography("");
            setCity("");
            setState("");
            setOccupation("");
            setMakePublic(false);
            setAllowLogging(false);
            setDeepFakeMode(1);
        }
        else {
            var cloneImagePath = getCloneImagePath(activeClone.id);
            setCloneImage(cloneImagePath);
            setCloneImageFile(null);
            document.getElementById("cloneImageInput").value = "";

            var cloneAudioSamplePath = getCloneAudioSamplePath(activeClone.id);
            setCloneAudio(cloneAudioSamplePath);
            setCloneAudioFile(null);
            document.getElementById("cloneAudioInput").value = "";

            setFirstName(activeClone.firstName);
            setLastName(activeClone.lastName);
            setNickName(activeClone.nickName);
            setAge(activeClone.age);
            setBiography(activeClone.biography);
            setCity(activeClone.city);
            setState(activeClone.state);
            setOccupation(activeClone.occupation);
            setMakePublic(activeClone.makePublic);
            setAllowLogging(activeClone.allowLogging);
            setDeepFakeMode(activeClone.deepFakeMode);
        }

        // always reset recording audio
        setIsRecording(false);
        cleanupAudioStreams(audioRecorder);
        setAudioRecorder(null);
        setAudioChunks([]);

        // always reset recording video
        cleanupVideoStreams(videoRef.current);
        //const [isCapturingPhoto, setIsCapturingPhoto] = React.useState(false);
        //const [videoRef, setVideoRef] = React.useState(React.createRef());
        //const [canvasRef, setCanvasRef] = React.useState(React.createRef());

    }
    React.useEffect(handleActiveCloneChanged, [activeClone])

    //////////////////////////////////////////////////////////////////
    ////////// MUTATE CLONE //////////////////////////////////////////
    //////////////////////////////////////////////////////////////////

    async function createClone() {
        await validateAndRun("cloneForm", async () => {
            async function _createClone() {
                window.showLoader(window.loader.CREATING_MESSAGE, true, "Clone Created");
                await post("/api/CloneCRUD/CreateClone", getCloneDTO());
                await loadClones();
                window.hideLoader();
            }


            showConfirmDialog({
                confirmationText: `This may take a couple minutes`,
                onConfirm: _createClone
            });
        });
    }

    async function updateClone() {
        async function _updateClone() {
            await validateAndRun("cloneForm", async () => {
                window.showLoader(window.loader.UPDATING_MESSAGE, true, "Updated");
                await post("/api/CloneCRUD/UpdateClone", getCloneDTO());
                await loadClones();
            });
        }

        var avRegen = cloneAudioFile || cloneImageFile;
        if (avRegen) {
            showConfirmDialog({
                confirmationText: `This may take a couple minutes`,
                onConfirm: _updateClone
            });
        }
        else {
            _updateClone();
        }
    }

    function getCloneDTO() {
        return generateFormData({
            id: activeClone ? activeClone.id : null,
            cloneImage: cloneImageFile,
            audioSample: cloneAudioFile,
            firstName: firstName,
            lastName: lastName,
            nickName: nickName,
            age: age,
            biography: biography,
            city: city,
            state: state,
            occupation: occupation,
            makePublic: makePublic,
            allowLogging: allowLogging,
            deepfakeMode: deepfakeMode
        });
    }

    async function deleteClone() {
        showConfirmDialog({
            confirmationText: `Are you sure you want to delete ${activeClone.firstName}? All data about this clone (except logs if they were enabled) will be permenantly deleted. Type the clone's first name to confirm.`,
            challenge: activeClone.firstName,
            onConfirm: async () => {
                window.showLoader(window.loader.DELETING_MESSAGE, true, "Clone Deleted");

                await post("/api/CloneCRUD/DeleteClone", activeClone.id);
                await loadClones();
                window.hideLoader();
            }
        })
    }

    //////////////////////////////////////////////////////////////////
    ////////// IDK YET... ////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////

    async function switchClone(selectedCloneId) {
        if (selectedCloneId == newCloneId) {
            setActiveClone(null);
        }
        else {
            window.showLoader();
            await post(`/api/ApplicationUser/SetActiveClone`, selectedCloneId);
            await loadClones();
            window.hideLoader();
            resetForm(cloneFormId);
        }
    }

    async function OnCloneImageSelected(e) {
        const file = e.target.files[0];
        if (file) {
            setCloneImage(URL.createObjectURL(file));
            setCloneImageFile(file);
        }
    }

    async function OnCloneAudioSampleSelected(e) {
        const file = e.target.files[0];
        if (file) {
            setCloneAudio(URL.createObjectURL(file));
            setCloneAudioFile(file);
        }
    }

    React.useEffect(() => {
        if (audioRef.current) {
            audioRef.current.load(); // reload the audio element
        }
    }, [cloneAudio]);

    //////////////////////////////////////////////////////////////////
    ////////// WEBCAM ////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////

    const cameraCapture = React.useMemo(() => createCameraCapture(
        // onCameraStart
        (stream) => {
            console.log("Camera started");
            setIsCapturingPhoto(true);
        },
        // onCameraStop
        () => {
            console.log("Camera stopped");
            setIsCapturingPhoto(false);
        },
        // onPhotoCapture
        ({ url, file }) => {
            console.log("Photo captured, URL:", url);
            console.log("File size:", file.size, "bytes");
            setCloneImage(url);
            setCloneImageFile(file);
            setIsCapturingPhoto(false);
        },
        // onCameraAvailable
        (isAvailable, devices) => {
            if (isAvailable) {
                // this should wait until you're ready to actually take the photo. it calls it available too soon.
            }
        },
        // onError
        (error) => {
            console.error("Camera error:", error);
            alert(`Camera error: ${error.message}`);
        }
    ), []);

    React.useEffect(() => {
        cleanupVideoStreams(videoRef.current);
    }, [isCapturingPhoto]);


    React.useEffect(() => {
    if (isCapturingPhoto && videoRef.current) {
        cameraCapture.startCamera(videoRef.current);
    }
}, [isCapturingPhoto, cameraCapture]);

    //////////////////////////////////////////////////////////////////
    ////////// MICROPHONE ////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////

    const microphonRecorder = React.useMemo(() => createAudioRecorder({
        onRecordingStart: (recorder) => {
            setAudioRecorder(recorder);
            setIsRecording(true);
        },
        onRecordingStop: () => {
            setIsRecording(false);
        },
        onAudioAvailable: ({ url, file }) => {
            setCloneAudio(url);
            setCloneAudioFile(file);
            setRecordedAudio(url); 
        },
        onAudioChunk: (chunks) => {
            setAudioChunks(chunks);
        },
        onError: (error) => {
            logError(`Microphone error: ${error.message}`);
        }
    }), []);

    React.useEffect(() => {
        return () => {
            cleanupAudioStreams(audioRecorder);
        };
    }, [audioRecorder]);

    React.useEffect(() => {
        if (audioRef.current) {
            audioRef.current.load(); // reload the audio element
        }
    }, [cloneAudio, recordedAudio]);

    return (
        <div className="container-fluid mt-5">
            <div className="row justify-content-center">
                <div className="col-lg-8 col-xl-7">
                    <div className="card">
                        <div className="card-header">
                            <h3 className="text-center">Manage Clones</h3>
                        </div>
                        <div className="card-body">
                            <div className="mb-3">
                                <label className="form-label">Select Clone Profile</label>
                                <select id="cloneSelector" className="form-select" onChange={(e) => switchClone(e.target.value)} value={activeClone ? activeClone.id : -1}>
                                    <option value={newCloneId} selected>New Clone</option>
                                    {userClones.map(clone => (
                                        <option key={clone.id} value={clone.id}>
                                            {clone.firstName}
                                        </option>
                                    ))}
                                </select>
                                <br></br>
                            </div>
                            <form id="cloneForm" noValidate>
                                <div className="mb-3">
                                    <div className="row g-2">









                                        <div className="col-md-6">
                                            <label className="form-label">Profile Image: <span className="text-danger">*</span></label>
                                            <div className="mb-3">
                                                <div className="img-thumbnail" style={{ width: '100%', height: '200px', backgroundColor: 'gray', position: 'relative' }}>
                                                    {!isCapturingPhoto ?
                                                        (<img src={cloneImage} alt="Profile placeholder" style={{ width: '100%', height: '100%', objectFit: 'contain' }}></img>)
                                                        :
                                                        (<video
                                                            ref={videoRef}
                                                            style={{ width: '100%', height: '100%', objectFit: 'contain' }}
                                                            autoPlay
                                                        ></video>)
                                                    }
                                                    <canvas ref={canvasRef} style={{ display: 'none' }}></canvas>
                                                </div>
                                            </div>















                                            <div className="mb-3">
                                                <div className="d-flex gap-2">
                                                    {!isCapturingPhoto ?
                                                        (<button
                                                            type="button"
                                                            className="btn btn-primary"
                                                            onClick={() => { setIsCapturingPhoto(true); }}>
                                                            <i className="bi bi-camera-fill"></i>Use Camera</button>)
                                                        :
                                                        (<>
                                                            <button
                                                                type="button"
                                                                className="btn btn-success"
                                                                onClick={() => {
                                                                    console.log("Take Photo clicked");
                                                                    console.log("Video element exists:", !!videoRef.current);
                                                                    console.log("Canvas element exists:", !!canvasRef.current);

                                                                    if (videoRef.current) {
                                                                        console.log("Video dimensions:", videoRef.current.videoWidth, "x", videoRef.current.videoHeight);
                                                                        console.log("Video is playing:", !videoRef.current.paused);
                                                                    }

                                                                    // Then call your functions
                                                                    cameraCapture.capturePhoto(videoRef.current, canvasRef.current);
                                                                    cameraCapture.stopCamera();
                                                                }}>
                                                                <i className="bi bi-camera"></i> Take Photo</button>
                                                            <button
                                                                type="button"
                                                                className="btn btn-warning"
                                                                onClick={() => {
                                                                    cameraCapture.stopCamera();
                                                                }}>
                                                                <i className="bi bi-x-circle"></i> Cancel
                                                            </button>
                                                        </>
                                                    )}
                                                </div>
                                            </div>








                                            <div className="text-muted mb-2">Choose a file or take a photo:</div>
                                            <input
                                                id="cloneImageInput"
                                                className="form-control"
                                                type="file"
                                                onChange={OnCloneImageSelected}
                                                accept="image/png, image/jpeg"
                                                required={activeClone == null && !cloneImageFile ? 'required' : undefined}
                                            />
                                            <div className="invalid-feedback">
                                                Profile image is required. Please upload a file or take a photo.
                                            </div>
                                        </div>








































                                        <div className="col-md-6">
                                            <label className="form-label">Audio Sample: <span className="text-danger">*</span></label>
                                            <div className="mb-3">
                                                <div className="audio-thumbnail">
                                                    <audio ref={audioRef} controls>
                                                        <source src={cloneAudio || recordedAudio} />
                                                    </audio>
                                                </div>
                                            </div>






                                            <div className="mb-3">
                                                <div className="d-flex gap-2">
                                                    {!isRecording ?
                                                        (<button
                                                            type="button"
                                                            className="btn btn-danger"
                                                            onClick={microphonRecorder.startRecording}>
                                                            <i className="bi bi-mic-fill"></i>Record Audio</button>
                                                        )
                                                        :
                                                        (<button
                                                            type="button"
                                                            className="btn btn-warning"
                                                            onClick={microphonRecorder.stopRecording}>
                                                            <i className="bi bi-stop-fill"></i>Stop Recording</button>
                                                        )
                                                    }
                                                </div>
                                            </div>

                                            <div className="text-muted mb-2">Choose a file or record directly:</div>
                                            <input
                                                id="cloneAudioInput"
                                                className="form-control"
                                                type="file"
                                                onChange={OnCloneAudioSampleSelected}
                                                accept=".mp3,.wav,.ogg,.flac,.m4a"
                                                required={activeClone == null && !cloneAudioFile && !recordedAudio ? 'required' : undefined}
                                            />
                                            <div className="invalid-feedback">
                                                Audio Sample is required. Please upload a file or record audio.
                                            </div>





                                        </div>
                                    </div>
                                </div>
                                <div className="row g-3">
                                    <div className="col-md-6">
                                        <label htmlFor="firstName" className="form-label">First Name <span className="text-danger">*</span></label>
                                        <input type="text" className="form-control" placeholder="Enter clone's first name" value={firstName} onChange={(e) => setFirstName(e.target.value)} required />
                                        <div className="invalid-feedback">
                                            First name is required.
                                        </div>
                                    </div>
                                    <div className="col-md-6">
                                        <label htmlFor="lastName" className="form-label">Last Name</label>
                                        <input type="text" className="form-control" placeholder="Enter clone's last name (optional)" value={lastName} onChange={(e) => setLastName(e.target.value)} />
                                    </div>
                                </div>
                                <div className="row g-3 mt-3">
                                    <div className="col-md-6">
                                        <label htmlFor="nickname" className="form-label">Nickname</label>
                                        <input type="text" className="form-control" placeholder="Enter clone's nickname (optional)" value={nickName} onChange={(e) => setNickName(e.target.value)} />
                                    </div>
                                    <div className="col-md-6">
                                        <label htmlFor="age" className="form-label">Age</label>
                                        <input type="number" className="form-control" placeholder="Enter clone's age (optional)" value={age} onChange={(e) => setAge(e.target.value)} step="1" />
                                    </div>
                                </div>
                                <div className="row g-3 mt-3">
                                    <div className="col-12">
                                        <label htmlFor="biography" className="form-label">Biography</label>
                                        <textarea className="form-control" rows="3" placeholder="Write a short biography (optional)" value={biography} onChange={(e) => setBiography(e.target.value)}></textarea>
                                    </div>
                                </div>
                                <div className="row g-3 mt-3">
                                    <div className="col-md-6">
                                        <label htmlFor="city" className="form-label">City</label>
                                        <input type="text" className="form-control" placeholder="Enter clone's city (optional)" value={city} onChange={(e) => setCity(e.target.value)} />
                                    </div>
                                    <div className="col-md-6">
                                        <label htmlFor="state" className="form-label">State</label>
                                        <input type="text" className="form-control" placeholder="Enter clone's state (optional)" value={state} onChange={(e) => setState(e.target.value)} />
                                    </div>
                                </div>
                                <div className="row g-3 mt-3">
                                    <div className="col-md-6">
                                        <label htmlFor="occupation" className="form-label">Occupation</label>
                                        <input type="text" className="form-control" placeholder="Enter clone's occupation (optional)" value={occupation} onChange={(e) => setOccupation(e.target.value)} />
                                    </div>
                                    <div className="mt-5 mt-md-1 col-md-6 d-flex align-items-center">
                                        <div className="d-flex">
                                            <div className="form-check me-3" data-bs-toggle="tooltip" title="If checked other users will be able to talk to your clone. This means any information you enter about your clone will be publicly available. Leave unchecked for privacy.">
                                                <input className="form-check-input" type="checkbox" id="makePublic" checked={makePublic} onChange={(e) => setMakePublic(e.target.checked)} />
                                                <label className="form-check-label" for="makePublic">
                                                    Make Public
                                                </label>
                                            </div>
                                            <div className="form-check" data-bs-toggle="tooltip" title="If checked some records of your conversations and interactions with this clone may be logged. Logs are useful for improving code quality and resolving errors. Leave unchecked for privacy. Third parties such as ElevenLabs and OpenAI do their own logging which can't be controlled here.">
                                                <input className="form-check-input" type="checkbox" id="allowLogging" checked={allowLogging} onChange={(e) => setAllowLogging(e.target.checked)} />
                                                <label className="form-check-label" for="allowLogging">
                                                    Allow Logging
                                                </label>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div className="row g-3 mt-3">
                                    <div className="col-md-6">
                                        <DeepFakeModeChooser selectedMode={deepfakeMode} onModeChange={setDeepFakeMode} />
                                    </div>
                                    <div className="col-md-6"></div>
                                </div>
                                <div className="d-grid gap-2 mt-4">
                                    {(activeClone == null || activeClone.id == -1) && (
                                        <button type="button" className="btn btn-primary" onClick={createClone}>Create Clone</button>
                                    )}
                                    {(activeClone && activeClone.id != -1) && (
                                        <>
                                            <button type="button" className="btn btn-primary" onClick={updateClone}>Update Clone</button>
                                            <button type="button" className="btn btn-danger" onClick={deleteClone}>Delete Clone</button>
                                        </>
                                    )}
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    );
}

ReactDOM.render(<CloneCRUD />, document.getElementById("root"));
