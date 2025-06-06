function GoTo(props) {
    const [logId, setLogId] = React.useState("");
    const [logIdNotFound, setLogIdNotFound] = React.useState(false);

    function handleLogIdChanged(event) {
        let logIdInt = parseInt(event.target.value, 10);
        setLogId(logIdInt);
    }

    function onGoto() {
        let logIdInFulllogList = props.FullLogListIds.current.indexOf(logId) != -1;
        setLogIdNotFound(!logIdInFulllogList);
        if(logIdInFulllogList) {
            props.OnGoTo(logId);
        }
    }

    return (
            <div class="modal" id={props.Id} tabindex="-1" aria-hidden="true">
                <div class="modal-dialog modal-dialog-centered modal-dialog-scrollable modal-xl">
                    <div class="modal-content">
                        <div class="modal-body">
                        <div class="input-group mb-3">
                            <input
                                type="number"
                                min="0"
                                step="1"
                                class="form-control"
                                placeholder="log_id"
                                aria-describedby="button-addon2"
                                value={logId}
                                onChange={handleLogIdChanged}
                            />
                            <button
                                class="btn btn-secondary"
                                type="button"
                                onClick={onGoto}
                            >
                                GoTo
                            </button>
                            </div>
                        </div>
                        <div class="modal-footer" hidden={!logIdNotFound}>
                            <div class="text-danger">Log ID not found</div>
                        </div>
                    </div>
                </div>
            </div>
    );
}
