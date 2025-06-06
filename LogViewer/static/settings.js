function Settings(props) {
    let defaultStartTime = 24 * 60 * 7  ;
    let defaultEndTime = 0;
    let minutesIn100Years = 60 * 24 * 365 * 100;
    let defaultPageSize = 250;

    const [startTimeEnabled, setStartTimeEnabled] = React.useState(true);
    const [endTimeEnabled, setEndTimeEnabled] = React.useState(false);
    const [startTime, setStartTime] = React.useState(
        utils.GetNowMinusNMinutesAsLocalTimeString(defaultStartTime)
    );
    const [endTime, setEndTime] = React.useState("");
    const [useLastNMinutes, setUseLastNMinutes] = React.useState("");
    const [pageSize, setPageSize] = React.useState(defaultPageSize);
    const [sessionLogsLength, setSessionLogsLength] = React.useState(0);
    const [displayedLogs, setDisplayedLogs] = React.useState({
        Website: true,
        SemanticSearch: true,
        SadTalker: true,
        ST_FFMPEG: true,
        U_2_Net: true,
        ThirdParty: false
    });

    function updateSettings() {
        props.onSettingsUpdate({
            startTime: startTime,
            endTime: endTime,
            useLastNMinutes: startTime == "" && endTime == "" ? useLastNMinutes : "", // this is to handle the state before you press the Set button
            pageSize: pageSize,
            displayedLogs: displayedLogs
        });
    }
    React.useEffect(updateSettings, [startTime, endTime, useLastNMinutes, pageSize, displayedLogs]);

    //////////////////////////////////////////////////////////////////
    ///////////// START TIME /////////////////////////////////////////
    //////////////////////////////////////////////////////////////////
    
    function updateStartTimeEnabled(e) {
        setStartTimeEnabled((prevEnabled) => {
            // Update startTime based on the new value of startTimeEnabled
            setStartTime((startTime) => {
                return !prevEnabled
                    ? utils.GetNowMinusNMinutesAsLocalTimeString(defaultStartTime)
                    : "";
            });
            return !prevEnabled; // Return the new state for startTimeEnabled
        });
        // whenever start/end times are touched we want to unset last n minutes
        setUseLastNMinutes("");
    }

    function handleStartTimeChange(event) {
        setStartTime(event.target.value);
    }

    //////////////////////////////////////////////////////////////////
    ///////////// END TIME ///////////////////////////////////////////
    //////////////////////////////////////////////////////////////////
    
    function updateEndTimeEnabled(e) {
        setEndTimeEnabled((prevEnabled) => {
            // Update endTime based on the new value of endTimeEnabled
            setEndTime((endTime) => {
                return !prevEnabled
                    ? utils.GetNowMinusNMinutesAsLocalTimeString(defaultEndTime)
                    : "";
            });
            return !prevEnabled; // Return the new state for endTimeEnabled
        });
        // whenever start/end times are touched we want to unset last n minutes
        setUseLastNMinutes("");
    }

    function handleEndTimeChange(event) {
        setEndTime(event.target.value);
    }

    //////////////////////////////////////////////////////////////////
    ///////////// COMMON START/END TIME //////////////////////////
    //////////////////////////////////////////////////////////////////
    
    function validateStartAndEndTimes() {
        let _startTime =
            startTime == ""
                ? utils.GetNowMinusNMinutesAsLocalTimeString(minutesIn100Years)
                : startTime;
        let _endTime =
            endTime == ""
                ? utils.GetNowMinusNMinutesAsLocalTimeString(-minutesIn100Years)
                : endTime;
        let startTimeAsDate = utils.LocalTimeStringToDate(_startTime);
        let endTimeAsDate = utils.LocalTimeStringToDate(_endTime);
        if (startTimeAsDate >= endTimeAsDate) {
            alert("start time must come before end time. resetting to default");
            if (startTimeEnabled) {
                setStartTime(
                    utils.GetNowMinusNMinutesAsLocalTimeString(defaultStartTime)
                );
            } else {
                setStartTime("");
            }
            setEndTime("");
            setEndTimeEnabled(false);
        }
    }
    React.useEffect(validateStartAndEndTimes, [startTime, endTime]);

    function disableStartAndEndTime() {
        setStartTime("");
        setStartTimeEnabled(false);
        setEndTime("");
        setEndTimeEnabled(false);
    }

    //////////////////////////////////////////////////////////////////
    ///////////// USE LAST N MINUTES /////////////////////////////////
    //////////////////////////////////////////////////////////////////
    
    function updateUseLastNMinutes() {
        if (isNaN(parseInt(useLastNMinutes, 10))) {
            return;
        }
        if (useLastNMinutes < 1) {
            setUseLastNMinutes(1);
        }
        disableStartAndEndTime();
    }

    function handleUseLastNMinutesChange(event) {
        setUseLastNMinutes(event.target.value);
    }

    //////////////////////////////////////////////////////////////////
    ///////////// PAGE SIZE //////////////////////////////////////////
    //////////////////////////////////////////////////////////////////

    function handlePageSizeChange(event) {
        var n = parseInt(event.target.value);
        if (isNaN(n)) {
            props.onError("PageSize must be an integer > 0");
        } else {
            setPageSize(n);
        }
    }

    //////////////////////////////////////////////////////////////////
    ///////////// CACHE //////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////

    function clearLogCache() {
        window.logCache.ClearLogCache();
        setSessionLogsLength(0);
    }

    React.useEffect(() => {
        // Function to update the length of session logs
        const updateSessionLogsLength = () => {
            const sessionLogsLength = window.logCache.GetSessionLogsLength();
            setSessionLogsLength(sessionLogsLength);
        };

        // Call the function to update the length
        updateSessionLogsLength();

        // Optional: Set up an interval or event listener to periodically update the length
        // For example, using an interval (you can adjust the interval time as needed)
        const interval = setInterval(updateSessionLogsLength, 1000); // Update every 1 second

        // Clean-up function to clear the interval
        return () => clearInterval(interval);

    }, []);

    //////////////////////////////////////////////////////////////////
    ///////////// DISPLAYED LOGS /////////////////////////////////////
    //////////////////////////////////////////////////////////////////

    function updateDisplayedLogs(e) {
        setDisplayedLogs(prev => {
            return {
                Website: e.target.title == "Website" ? !prev.Website : prev.Website,
                SemanticSearch: e.target.title == "Semantic Search" ? !prev.SemanticSearch : prev.SemanticSearch,
                SadTalker: e.target.title == "SadTalker" ? !prev.SadTalker : prev.SadTalker,
                ST_FFMPEG: e.target.title == "ST_FFMPEG" ? !prev.ST_FFMPEG : prev.ST_FFMPEG,
                U_2_Net: e.target.title == "U-2-Net" ? !prev.U_2_Net : prev.U_2_Net,
                ThirdParty: e.target.title == "Third Party" ? !prev.ThirdParty : prev.ThirdParty,
            }
        });
    }

    return (
        <div>
            <img
                src="/static/settings.webp"
                className="settings-icon"
                data-bs-toggle="modal"
                data-bs-target="#settingsModal"
            />

            <div class="modal" id="settingsModal" tabindex="-1" aria-hidden="true">
                <div class="modal-dialog modal-dialog-centered modal-dialog-scrollable modal-xl">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h1 class="modal-title fs-5" id="settingsModalLabel">
                                Log Viewer Settings
                            </h1>
                            <button
                                type="button"
                                class="btn-close"
                                data-bs-dismiss="modal"
                            ></button>
                        </div>
                        <div class="modal-body">
                            <div className="container-fluid">
                                <div className="row">
                                    <div className="col-4">
                                        <label htmlFor="datetimeStart">Start Time</label>
                                        <div className="input-group mb-3">
                                            <div className="input-group-text">
                                                <input
                                                    className="form-check-input mt-0 checkbox-2x"
                                                    type="checkbox"
                                                    onClick={updateStartTimeEnabled}
                                                    checked={startTimeEnabled}
                                                />
                                            </div>
                                            <input
                                                type="datetime-local"
                                                value={startTime}
                                                onChange={handleStartTimeChange}
                                                id="datetimeStart"
                                                disabled={!startTimeEnabled}
                                                className={
                                                    "form-control " +
                                                    (!startTimeEnabled ? "disabled-date" : "")
                                                }
                                            />
                                        </div>
                                    </div>
                                    <div className="col-4">
                                        <label htmlFor="datetimeEnd">End Time</label>
                                        <div className="input-group mb-3">
                                            <div className="input-group-text">
                                                <input
                                                    className="form-check-input mt-0 checkbox-2x"
                                                    type="checkbox"
                                                    onClick={updateEndTimeEnabled}
                                                    checked={endTimeEnabled}
                                                />
                                            </div>
                                            <input
                                                type="datetime-local"
                                                value={endTime}
                                                onChange={handleEndTimeChange}
                                                id="datetimeEnd"
                                                disabled={!endTimeEnabled}
                                                className={
                                                    "form-control " +
                                                    (!endTimeEnabled ? "disabled-date" : "")
                                                }
                                            />
                                        </div>
                                    </div>
                                    <div className="col-4">
                                        <label htmlFor="setLastNMinutes">Last n Minutes</label>
                                        <div class="input-group mb-3">
                                            <input
                                                type="number"
                                                min="1"
                                                step="1"
                                                class="form-control"
                                                placeholder="n minutes"
                                                aria-describedby="button-addon2"
                                                value={useLastNMinutes}
                                                onChange={handleUseLastNMinutesChange}
                                            />
                                            <button
                                                class="btn btn-secondary"
                                                type="button"
                                                id="setLastNMinutes"
                                                onClick={updateUseLastNMinutes}
                                            >
                                                Set
                                            </button>
                                        </div>
                                    </div>
                                </div>
                                <div className="row">
                                    <div className="col-12">
                                        <hr className="mb-4" />
                                    </div>
                                </div>
                                <div className="row">
                                    <div className="col-4">
                                        <div className="row g-3 align-items-center">
                                            <div className="col-auto">
                                                <label for="inputPageSize" className="col-form-label">
                                                    PageSize
                                                </label>
                                            </div>
                                            <div className="col">
                                                <input
                                                    type="number"
                                                    min="1"
                                                    step="1"
                                                    id="inputPageSize"
                                                    className="form-control"
                                                    value={pageSize}
                                                    onChange={handlePageSizeChange}
                                                />
                                            </div>
                                        </div>
                                    </div>
                                    <div className="col-4">
                                        <div className="row g-3 align-items-center">
                                            <div className="col-auto">
                                                <label for="inputPageSize" className="col-form-label">
                                                Log Cache Size: {sessionLogsLength}
                                                </label>
                                            </div>
                                            <div className="col">
                                                <button type="button" class="btn btn-warning" onClick={clearLogCache}>Clear</button>
                                            </div>
                                        </div>
                                    </div>
                                    <div className="col-4">
                                        <div class="btn-group" role="group" id="displayedLogsChooser" onClick={updateDisplayedLogs}>
                                            <button type="button" className={(displayedLogs.Website ? "btn-secondary" : "btn-outline-secondary") + " btn"} title="Website">W</button>
                                            <button type="button" className={(displayedLogs.SemanticSearch ? "btn-secondary" : "btn-outline-secondary") + " btn"} title="Semantic Search">S</button>
                                            <button type="button" className={(displayedLogs.SadTalker ? "btn-secondary" : "btn-outline-secondary") + " btn"} title="SadTalker">😔</button>
                                            <button type="button" className={(displayedLogs.ST_FFMPEG ? "btn-secondary" : "btn-outline-secondary") + " btn"} title="ST_FFMPEG">F</button>
                                            <button type="button" className={(displayedLogs.U_2_Net ? "btn-secondary" : "btn-outline-secondary") + " btn"} title="U-2-Net">U</button>
                                            <button type="button" className={(displayedLogs.ThirdParty ? "btn-secondary" : "btn-outline-secondary") + " btn"} title="Third Party">3</button>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    );
}
