window.data = (function() {
    function getLogIds(querySettings) {
        // Define the request options
        const requestOptions = {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(querySettings) // Send querySettings as JSON in the request body
        };
    
        // Make a POST request
        return fetch('/get-log-ids', requestOptions)
            .then(response => {
                if (!response.ok) {
                    throw new Error(`HTTP error! Status: ${response.status}`);
                }
                return response.json();
            })
            .then(data => {
                return data.logIds;
            })
            .catch(error => {
                console.error('Error fetching log IDs:', error);
                throw error; // Propagate the error
            });
    }

    function getLogs(queryObject) {
        if (queryObject.length === 0) {
            return Promise.resolve([]);
        }

        let logIdsNotInSession = window.logCache.GetLogIdsNotInSessionLogs(queryObject.pageIds);
        let logsInSession = window.logCache.GetSessionLogs(queryObject.pageIds);

        console.log(`logs in cache: ${logsInSession.length} | logs fetched from server: ${logIdsNotInSession.length}`)
        if(logIdsNotInSession == 0) {
            return Promise.resolve(logsInSession);
        }

        queryObject.pageIds = logIdsNotInSession; 
        const requestOptions = {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(queryObject) 
        };
    
        // Make a POST request
        return fetch('/get-logs', requestOptions)
            .then(response => {
                if (!response.ok) {
                    console.error(response);
                    throw new Error(`HTTP error! Status: ${response.status}`);
                }
                return response.json();
            })
            .then(data => {
                data.logs.forEach(log => {
                    if(log["message"].indexOf("img") != -1) {
                        //debugger;
                    }
                    log.timestamp = new Date(log.timestamp)
                    log["human_readable_timestamp"] = utils.DateToHumanReadable(log.timestamp)
                    log.tags = "Tags: [" + log.tags + "]";
                    //log.message = log.message.replace(/ /g, "&nbsp;").replace(/\t/g, "TABBBBBB")
                });
                window.logCache.AddSessionLogs(data.logs);
                let result = utils.ConcatAndSortArrays(logsInSession, data.logs, "log_id", queryObject.descending);

                return result;
            })
            .catch(error => {
                console.error('Error fetching logs:', error);
                throw error; // Propagate the error
            });
    }
    
    return {
        GetLogIds: getLogIds,
        GetLogs: getLogs
    }
})();