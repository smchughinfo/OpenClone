import psycopg2
import GlobalVariables
import Utils

class Data():
    def __init__(self):
        self.initDb()

    #############################################################
    ###### PUBLIC ###############################################
    #############################################################
    
    def getLogIds(self, queryParams):
        (sql, params) = self.getIdsQuery(queryParams)
        (column_names, rows) = self.doQuery(sql, params)
        id_array = [row[0] for row in rows]
        return id_array

    def getLogs(self, queryParams):
        # Ensure queryParams is a tuple, which is required for psycopg2
        params = (tuple(queryParams.get("pageIds")),)
        order_clause = "DESC" if queryParams.get("descending") else "ASC"
        sql = f"SELECT * FROM log WHERE log_id IN %s ORDER BY log_id {order_clause}"

        (column_names, rows) = self.doQuery(sql, params)
        logs = [dict(zip(column_names, row)) for row in rows]
        return logs

    #############################################################
    ###### HELPERS ##############################################
    #############################################################

    def getIdsQuery(self, queryParams):
        conditions = []
        params = []

        if queryParams["useLastNMinutes"] != "":
            n = int(queryParams["useLastNMinutes"])
            startTime = Utils.now_minus_n_minutes_as_postgres_format(n)
            conditions.append("timestamp >= %s")
            params.append(startTime)
        else:
            if queryParams["startTime"] != "":
                conditions.append("timestamp >= %s")
                params.append(queryParams["startTime"])

            if queryParams["endTime"] != "":
                conditions.append("timestamp <= %s")
                params.append(queryParams["endTime"])
        
        if queryParams['displayedLogs']['Website'] == False:
            conditions.append("application_name <> 'Website'")
        if queryParams['displayedLogs']['SemanticSearch'] == False:
            conditions.append("application_name <> 'SemanticSearch'")
        if queryParams['displayedLogs']['SadTalker'] == False:
            conditions.append("application_name <> 'SadTalker'")
        if queryParams['displayedLogs']['ST_FFMPEG'] == False:
            conditions.append("application_name <> 'ST_FFMPEG'")
        if queryParams['displayedLogs']['U_2_Net'] == False:
            conditions.append("application_name <> 'U-2-Net'")
        if queryParams['displayedLogs']['ThirdParty'] == False:
            conditions.append("open_clone_log = true")

        where_clause = " AND ".join(conditions) if conditions else "1=1"

        order_clause = "DESC" if queryParams.get("descending") else "ASC"

        sql = f"SELECT log_id FROM log WHERE {where_clause} ORDER BY log_id {order_clause}"

        return (sql, params)


    #############################################################
    ###### DB INTERFACE##########################################
    #############################################################

    def initDb(self):
        global db_connection
        db_connection = psycopg2.connect(host=GlobalVariables.dbHost, port=GlobalVariables.dbPort, dbname=GlobalVariables.dbName, user=GlobalVariables.dbUser, password=GlobalVariables.dbUserPassword)
        db_connection.autocommit = True

    def doQuery(self, sql, params):
        with db_connection.cursor() as cursor:
            cursor.execute(sql, params)
            rows = cursor.fetchall()
            column_names = [desc[0] for desc in cursor.description]
            return (column_names, rows)