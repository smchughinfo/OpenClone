from datetime import datetime, timedelta

def jsStringToDate(date_string, defaultDate):
    if(date_string == ""):
        return defaultDate
    else:
        return datetime.strptime(date_string, "%Y-%m-%dT%H:%M")
    
def datetime_to_postgres_format(dt):
    return dt.strftime("%Y-%m-%d %H:%M:%S")

def datetime_minus_n_minutes(dt, n):
    return dt - timedelta(minutes=n)

def now_minus_n_minutes_as_postgres_format(n):
    dt = datetime_minus_n_minutes(datetime.now(), n)
    return datetime_to_postgres_format(dt)