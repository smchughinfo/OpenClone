
function LogTable(props) {
    // IMPORTANT - log page refers to the concept of paging, not the html page in the browser.
    //             e.g. we have the logs on page n (out of 123 pages)

    // Logs and Log Paging
    const fullLogListIds = React.useRef([]);
    const [logPage, setLogPage] = React.useState([]); // IMPORTANT - THIS LINE KICKS IT ALL OFF. the [] changes state from undefined to [] which triggers useEffect(scheduleUpdate,[logpage])
    const getNextPage = React.useRef(true);
    const [showWaitingMessage, setShowWaitingMessage] = React.useState(true);
    const prevScrollPosition = React.useRef(0);
    const resetLogPage = React.useRef(false);
    const descending = React.useRef(true);

    // other stuff
    const querySettings = React.useRef({});
    const [errorMessage, setErrorMessage] = React.useState("");
    const [detailsView, setDetailsView] = React.useState(true);
    const gotoModal = React.useRef(null);
    const gotoLogId = React.useRef(null);

    //////////////////////////////////////////////////////////////////
    ////////// PAGING (MAIN SETTERS) /////////////////////////////////
    //////////////////////////////////////////////////////////////////

    function updateFullLogListIds() {
        let queryObject = {
            ...querySettings.current,
            descending: descending.current
        };
        window.data.GetLogIds(queryObject).then((logIds) => {
            fullLogListIds.current = logIds;
            updateLogPage();
        })
            .catch(displayError);
    };

    function updateLogPage() {
        let queryObject = {
            pageIds: gotoLogId.current != null ? getLogPageIdsForGoTo() : getLogPageIds(),
            descending: descending.current
        };
        getNextPage.current = false; // this is set here instead of after setLogPage in the following closure to emphasize that because state updates are async these two lines, though interconnected, cannot be thought of as executing one line after the other
        window.data.GetLogs(queryObject).then((logs) => {
            setLogPage(logs);
            setShowWaitingMessage(false);
        })
        .catch(displayError);
    }

    //////////////////////////////////////////////////////////////////
    ////////// PAGING (LOGIC) ////////////////////////////////////////
    //////////////////////////////////////////////////////////////////

    function getLogPageIds(includePages = 0) {
        let min = 0;

        let max;
        let pageSize = querySettings.current.pageSize;
        let firstLoad = logPage.length == 0;
        let onPage1 = !includePages && (firstLoad || resetLogPage.current)
        if (onPage1) {
            max = pageSize;
            resetLogPage.current = false;
        }
        else {
            let nextPageDelta = 0;
            if (includePages) {
                nextPageDelta = pageSize * includePages;
            }
            else if (getNextPage.current) {
                nextPageDelta = pageSize;
            }
            
            max = logPage.length + nextPageDelta;
        }

        // im too dumb to figure all the scenarios out so just doing this. hopefully it catches enough scenarios...
        max = max > pageSize ? max : pageSize;

        let r = fullLogListIds.current.slice(min, max);
        console.log(`min:${min}|max:${max}|fullLogListIds.length:${fullLogListIds.current.length}|curLogPage.length:${logPage.length}|newLogPage.Length:${r.length}|pageSize:${pageSize}`);
        return r; // the +1 on the second argument here is what makes maxInclusive act inclusive
    }

    function getLogPageIdsForGoTo() {
        let logPageNumber = 0;
        while(logPageNumber++ < 1000) {
            let logPageIds = getLogPageIds(logPageNumber);
            if(logPageIds.includes(gotoLogId.current)) {
                console.log(gotoLogId.current + " FOUND ", logPageIds);
                return logPageIds;
            }
        }
        setErrorMessage("GOTO Reality Check")
    }

    //////////////////////////////////////////////////////////////////
    ////////// PAGING (UPDATE SCHEDULER) /////////////////////////////
    //////////////////////////////////////////////////////////////////

    const throttleTimeoutRef = React.useRef(null);
    function scheduleUpdate() {
        // Only set the timeout if it's not already set
        if (!throttleTimeoutRef.current) {
            throttleTimeoutRef.current = setTimeout(() => {
                // your update logic here
                updateFullLogListIds();

                // Clear the timeout reference after the update is executed
                throttleTimeoutRef.current = null;
            }, 1000);
        }
    };

    React.useEffect(scheduleUpdate, [logPage]);

    //////////////////////////////////////////////////////////////////
    ////////// NEXT PAGE ON SCROLL ///////////////////////////////////
    //////////////////////////////////////////////////////////////////

    function handleWheel(e) {
        let goingDown = e.deltaY > 0;
        let noWindowScrollbar = document.body.scrollHeight < window.innerHeight;
        if (goingDown && noWindowScrollbar) {
            setShowWaitingMessage(true);
            getNextPage.current = true;
        }
    }

    function handleScroll(e) {
        let currentScrollPos = window.scrollY || document.documentElement.scrollTop;
        let a = window.innerHeight + currentScrollPos;
        let b = document.documentElement.offsetHeight;
        let diff = Math.abs(a - b);
        if (currentScrollPos > prevScrollPosition.current && diff < 10) {
            setShowWaitingMessage(true);
            getNextPage.current = true;
        }
        prevScrollPosition.current = currentScrollPos
    };

    React.useEffect(() => {
        window.addEventListener('scroll', handleScroll);
        window.addEventListener('wheel', handleWheel);

        return () => {
            window.removeEventListener('scroll', handleScroll);
            window.removeEventListener('wheel', handleWheel);
        };
    }, []);

    //////////////////////////////////////////////////////////////////
    ////////// SETTINGS //////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////

    function updateSettings(_querySettings) {
        resetLogPage.current = resetLogPage.current || _querySettings.pageSize < querySettings.current.pageSize; // only unset when setting curPage. avoids 25 setting this true 2<250 and then false 25>2
        querySettings.current = _querySettings;
        setShowWaitingMessage(true);
    }

    //////////////////////////////////////////////////////////////////
    ////////// ERROR MESSAGE /////////////////////////////////////////
    //////////////////////////////////////////////////////////////////

    function displayError(error) {
        setErrorMessage("error getting logs. check console");
        console.error(error);
    }

    function clearErrorMessage() {
        setErrorMessage("");
    }

    //////////////////////////////////////////////////////////////////
    ////////// DETAILS VIEW //////////////////////////////////////////
    //////////////////////////////////////////////////////////////////

    function toggleDetailsView() {
        setDetailsView((prev) => {
            return !prev;
        });
    }

    function toggleOrder() {
        descending.current = !descending.current;
        resetLogPage.current = true;
        setShowWaitingMessage(true);
    }

    //////////////////////////////////////////////////////////////////
    ////////// GOTO LOG ID //////////////////////////////////////////
    //////////////////////////////////////////////////////////////////

    let goToId = "gotoModal"
    function setGoToModalVisibility(visible) {
        if(visible) {
            gotoModal.current = new bootstrap.Modal(document.getElementById(goToId), {
                keyboard: false
            });
            gotoModal.current.show();
        }
        else {
            gotoModal.current.hide();
        }
    }
    function openGoToLogModal() {
        setGoToModalVisibility(true);
    }

    function goToLogId(logId) {
        setGoToModalVisibility(false);
        gotoLogId.current = logId;
    }

    function scrollToGoto() {
        if(gotoLogId.current != null) {
            window.utils.ScrollToElement("#log_id_" + gotoLogId.current);
            gotoLogId.current = null;
        }
    }
    React.useEffect(scrollToGoto, [logPage]);

    //////////////////////////////////////////////////////////////////
    ////////// JSX ///////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////

    return (
        <div>
            <div
                onClick={clearErrorMessage}
                className="alert alert-danger logtable-error-message"
                role="alert"
                hidden={errorMessage == ""}
            >
                {errorMessage}
            </div>
            <div className="quick-options" >
                <span title="GoTo" onClick={openGoToLogModal}>⤵️</span>
                <span title="Order" onClick={toggleOrder}>🔃</span>
                <span title="Show Details" onClick={toggleDetailsView}>💢</span>
            </div>
            <Settings onSettingsUpdate={updateSettings} onError={setErrorMessage} Descending={descending} />

            <GoTo Id={goToId} OnGoTo={goToLogId} FullLogListIds={fullLogListIds} />

            <table class="table table-borderless table-sm" id="logTable">
                <thead>
                    <tr>
                        {detailsView && <th className="log-header-column">Log Header</th>}
                        <th className="log-body-column">Log Body</th>
                    </tr>
                </thead>
                <LogTableBody
                    LogPage={logPage}
                    DetailsView={detailsView}
                />
            </table>
            <div className="alert alert-info next-page-alert" role="alert" hidden={!showWaitingMessage}>
                <span className="loading">Loading...</span>
                <GroovySpinner />
            </div>
        </div>
    );
}

ReactDOM.render(<LogTable />, document.getElementById("root"));
