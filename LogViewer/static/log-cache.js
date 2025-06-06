window.logCache = (function() {

    function getSessionLogs(sessionIds) {
        // Retrieve the session logs from sessionStorage
        let sessionLogs = JSON.parse(sessionStorage.getItem('jtm5_session')) || {};
    
        // Filter and return logs that match the provided sessionIds
        return sessionIds.map(id => sessionLogs[id]).filter(log => log !== undefined);
    }
    
    function addSessionLogs(newLogs) {
        // Check if 'jtm5_session' exists in sessionStorage, if not, initialize it
        if (!sessionStorage.getItem('jtm5_session')) {
            sessionStorage.setItem('jtm5_session', JSON.stringify({}));
        }
    
        // Retrieve the existing session logs
        let sessionLogs = JSON.parse(sessionStorage.getItem('jtm5_session'));
        
        // Add new logs to the session object
        newLogs.forEach(log => {
            sessionLogs[log.log_id] = log;
        });
    
        // Save the updated session logs back to sessionStorage
        sessionStorage.setItem('jtm5_session', JSON.stringify(sessionLogs));
    }
    
    
    function getLogIdsNotInSessionLogs(sessionIds) {
        // Retrieve the session logs from sessionStorage
        let sessionLogs = JSON.parse(sessionStorage.getItem('jtm5_session')) || {};
    
        // Convert stored log IDs to a Set for faster lookup
        let storedLogIdsSet = new Set(Object.keys(sessionLogs));
    
        // Return sessionIds that are not in storedLogIdsSet
        return sessionIds.filter(id => !storedLogIdsSet.has(String(id)));
    }
    
    function getSessionLogsLength() {
        let sessionLogs = JSON.parse(sessionStorage.getItem('jtm5_session')) || {};
        return Object.keys(sessionLogs).length;
    }

    function clearLogCache() {
        sessionStorage.setItem('jtm5_session', JSON.stringify({}));
    }

    return {
        GetSessionLogs: getSessionLogs,
        AddSessionLogs: addSessionLogs,
        GetLogIdsNotInSessionLogs: getLogIdsNotInSessionLogs,
        GetSessionLogsLength: getSessionLogsLength,
        ClearLogCache: clearLogCache
    }
})();
