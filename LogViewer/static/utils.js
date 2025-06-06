window.utils = (function() {

    //////////////////////////////////////////////////////////////////
    ///////////// DATETIMES //////////////////////////////////////////
    //////////////////////////////////////////////////////////////////

    function dateToHumanReadable(date) {
        const pad = (num, size = 2) => num.toString().padStart(size, '0');
        const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    
        let day = pad(date.getDate());
        let month = months[date.getMonth()];
        let year = date.getFullYear();
        let hours = pad(date.getHours());
        let minutes = pad(date.getMinutes());
        let seconds = pad(date.getSeconds());
        let milliseconds = pad(date.getMilliseconds(), 4); // Pad to 4 digits
    
        return `[${day} ${month} ${year} - ${hours}:${minutes}:${seconds}.${milliseconds}]`;
    }

    function dateToLocalTimeString(date) {
        // Format the date and time to match the datetime-local input requirements
        let year = date.getFullYear();
        let month = (date.getMonth() + 1).toString().padStart(2, '0'); // getMonth() is zero-based
        let day = date.getDate().toString().padStart(2, '0');
        let hours = date.getHours().toString().padStart(2, '0');
        let minutes = date.getMinutes().toString().padStart(2, '0');

        // Construct the datetime-local format string
        let dateTimeLocalString = `${year}-${month}-${day}T${hours}:${minutes}`;

        return dateTimeLocalString;
    }

    function localTimeStringToDate(localTimeString) {
        // Split the date and time parts
        const [date, time] = localTimeString.split('T');
    
        // Split the date part into year, month, and day
        const [year, month, day] = date.split('-').map(num => parseInt(num, 10));
    
        // Split the time part into hours and minutes
        const [hours, minutes] = time.split(':').map(num => parseInt(num, 10));
    
        // Create a new Date object using the year, month, day, hours, and minutes
        // Note: The month in JavaScript Date is 0-indexed, so subtract 1 from the month
        return new Date(year, month - 1, day, hours, minutes);
    }

    function getNowMinusNMinutes(n) {
        let date = new Date();
        date.setMinutes(date.getMinutes() - n);
        return date
    }

    function getNowMinusNMinutesAsLocalTimeString(n) {
        let date = getNowMinusNMinutes(n)
        return dateToLocalTimeString(date)
    }

    function concatAndSortArrays(array1, array2, key, descending) {
        // Concatenate the two arrays
        const combinedArray = array1.concat(array2);
    
        // Sort the combined array by the specified key
        combinedArray.sort((a, b) => {
            if (a[key] < b[key]) {
                return -1;
            }
            if (a[key] > b[key]) {
                return 1;
            }
            return 0;
        });
    
        return descending ? combinedArray.reverse() : combinedArray;
    }

    //////////////////////////////////////////////////////////////////
    ///////////// UI CONTROL /////////////////////////////////////////
    //////////////////////////////////////////////////////////////////

    function getTopmostVisibleElements(selector) {
        const elements = document.querySelectorAll(selector);
        let topmostElements = [];
        let distances = [];
        
        elements.forEach(element => {
            const rect = element.getBoundingClientRect();
            
            // Check if the element is within the viewport vertically
            if (rect.top >= 0 && rect.bottom <= window.innerHeight) {
                distances.push(rect.top);
                topmostElements.push(element);
            }
        });
        
        // Sort the elements based on their distance from the top
        const sortedIndices = distances
            .map((distance, index) => [distance, index])
            .sort(([a], [b]) => a - b)
            .map(([, index]) => index);
        
        // Return the top 10 elements
        return sortedIndices.slice(0, 99999).map(index => topmostElements[index]);
    }

    function scrollToElement(selector) {
        document.querySelector(selector).scrollIntoView({ behavior: 'smooth', block: 'nearest' });
    }
    
    return {
        DateToHumanReadable: dateToHumanReadable,
        DateToLocalTimeString: dateToLocalTimeString,
        GetNowMinusNMinutes: getNowMinusNMinutes,
        GetNowMinusNMinutesAsLocalTimeString: getNowMinusNMinutesAsLocalTimeString,
        LocalTimeStringToDate: localTimeStringToDate,
        ConcatAndSortArrays: concatAndSortArrays,
        GetTopmostVisibleElements: getTopmostVisibleElements,
        ScrollToElement: scrollToElement,
    }
})();