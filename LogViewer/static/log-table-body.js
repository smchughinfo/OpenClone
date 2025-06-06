function LogTableBody(props) {
    const [highlightedRows, setHighlightedRows] = React.useState({});

    function highlightRow(index, event, log_id) {
        // Check if Shift key was down when the mouse event was fired
        if (event.ctrlKey) {
            setHighlightedRows((prevState) => ({
                ...prevState,
                [log_id]: !prevState[log_id],
            }));
        } else {
            setHighlightedRows((prevState) => {
                let newState = {};
                for (let key in prevState) {
                    newState[key] = false; // Set all rows to unhighlighted
                }
                return newState;
            });
        }
    }

    function getApplicationIdentifierClassForRow(logTableRecord) {
        let applicationName = logTableRecord["application_name"].toLowerCase();
        if (applicationName == "a2f") {
            let isViewportStreamer = logTableRecord.tags.indexOf("viewport_streamer") != -1;
            if (isViewportStreamer) {
                return "viewport-streamer-row";
            }
        }
        return applicationName + "-row";
    }

    return (
        <tbody>
            {
                //(props.Order ? [...props.LogPage].reverse() : props.LogPage)
                props.LogPage
                .map((LogTableRecord, i) => (
                <tr
                    key={i}
                    onClick={(event) => highlightRow(i, event, LogTableRecord["log_id"])}
                    className={
                        "log-row " +
                        (highlightedRows[LogTableRecord["log_id"]] ? "highlighted" : "") +
                        " " +
                        getApplicationIdentifierClassForRow(LogTableRecord)
                    }
                    id={"log_id_" + LogTableRecord["log_id"]}
                >
                    {
                        props.DetailsView &&
                        <td>
                            <div className="log-header">
                                <div>
                                    <span>ID:{LogTableRecord["log_id"]}</span>
                                    <span>RUN:{LogTableRecord["run_number"]}</span>
                                    <span>{LogTableRecord["application_name"]}</span>
                                </div>
                                <div>
                                    <span>{LogTableRecord["machine_name"]}</span>
                                    <span>{LogTableRecord["ip_address"]}</span>
                                    <span>{LogTableRecord["level"]}</span>
                                </div>
                                <div>
                                    <span>{LogTableRecord["human_readable_timestamp"]}</span>
                                    <span
                                        className={
                                            LogTableRecord["open_clone_log"] ? "" : "open-clone-log-n"
                                        }
                                    >
                                        OpenClone
                                    </span>
                                </div>
                            </div>
                        </td>
                    }
                    <td className="log-body-and-header-overflow">
                        <div className="log-body">
                            {/* Use __html key to set inner HTML */}
                            <span
                                className="message"
                                dangerouslySetInnerHTML={{ __html: LogTableRecord["message"] }}
                            ></span>
                            {
                                props.DetailsView &&
                                <span>{LogTableRecord["tags"]}</span>
                            }
                        </div>
                    </td>
                </tr>
            ))}
        </tbody>
    );
}