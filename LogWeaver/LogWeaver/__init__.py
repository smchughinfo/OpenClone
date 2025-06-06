import logging
import json
import datetime
import socket
import queue
import threading
import time
import atexit
import os
import sys

logweaver_root_directory = os.path.join(os.path.dirname(__file__), "..")
sys.path.append(logweaver_root_directory)
import psycopg2
import pytz

_logweavers = []
eastern = pytz.timezone('US/Eastern')

class LogWeaver(logging.Handler):
    INFO = logging.INFO
    WARNING = logging.WARNING
    DEBUG = logging.DEBUG
    ERROR = logging.ERROR
    CRITICAL = logging.CRITICAL

    def __init__(self, applicationName, applicationServerIpAdress, level=logging.INFO, loggerName=None):
        super().__init__(level)

        # variables that can be set at start of __init__
        self.applicationName = applicationName
        self.ipAddress = applicationServerIpAdress
        self.machineName = socket.gethostbyaddr(applicationServerIpAdress)[0]
        self.loggerName = loggerName

        # logging setup
        self.logger = logging.getLogger(self.loggerName)
        self.logger.setLevel(level)
        if self.loggerName != None:
            self.logger.propagate = False # avoid named loggers propagating log to parent root logger which causes double log. but if logger name is None it grabs the root logger, so dont mess with that
        #logging.basicConfig(level=level)
        self.logger.addHandler(self)

        # run number
        self.runNumber = self.get_run_number()

        _logweavers.append(self)
        
    def emit(self, record):
        message_object = None
        default_logger = True if self.loggerName == None else False
        if default_logger:
            formatted_message = ""
            try:
                formatted_message = record.msg % record.args
            except:
                formatted_message = record.msg + " - Could not ToString() args"
            message_json = self.messageToJSON(formatted_message, record.levelno, False)
            message_object = json.loads(message_json)
        else:
            message_object = json.loads(record.msg)
        global log_queue
        log_queue.put(message_object)

    def messageToJSON(self, message, level=logging.INFO, openCloneLog=False, tagsArray=[]):
        timestamp = datetime.datetime.now(pytz.utc).astimezone(eastern).isoformat()
        log_entry = {
            "application_name": self.applicationName,
            "open_clone_log": openCloneLog,
            "timestamp": timestamp,
            "message": message,
            "tags": ','.join(tagsArray),
            "level": logging.getLevelName(level),
            "machine_name": self.machineName,
            "ip_address": self.ipAddress,
            "run_number": self.runNumber
        }
        return json.dumps(log_entry)

    def log(self, message, level=logging.INFO, tagsArray=[], isThirdParty = False):
        log_message = self.messageToJSON(message, level, isThirdParty != True, tagsArray)
        if(level==logging.INFO):
            self.logger.info(log_message)
        elif(level==logging.WARNING):
            self.logger.warning(log_message)
        elif(level==logging.ERROR):
            self.logger.error(log_message)
        elif(level==logging.DEBUG):
            self.logger.debug(log_message)
        else:
            self.logger.critical(log_message)

    def increment_run_number(self):
        global loq_queue
        self.runNumber = self.get_run_number() + 1
        jsonMessage = self.messageToJSON(f"{self.applicationName} - Run Number Incremented", openCloneLog=True)
        objectMessage = json.loads(jsonMessage)
        log_queue.put(objectMessage)
        LogWeaver._flush_log()

        global _logweavers
        otherApplicationLogWeavers = [lw for lw in _logweavers if lw.applicationName == self.applicationName and lw is not self]
        for lw in otherApplicationLogWeavers:
            lw.runNumber = self.runNumber

    def get_run_number(self):
        def dbOp(cursor):
            sql = "SELECT run_number FROM log WHERE application_name = %s AND machine_name = %s ORDER BY run_number DESC LIMIT 1"
            cursor.execute(sql, (self.applicationName, self.machineName))
            result = cursor.fetchone()
            return result[0] if result else 0
        return LogWeaver.get_cursor(dbOp)

    @staticmethod
    def get_cursor(dbOp):
        global db_connection
        try:
            with db_connection.cursor() as cursor:
                return dbOp(cursor)
        except Exception as e:
            # todo: this is the where the rubber hits the road with logging. if an exception is raised how are you going to log the logger? 
            print(e)
            raise(e)

    @staticmethod
    def init_db(dbHost, dbPort, dbName,dbUser,dbUserPassword):
        global db_connection
        db_connection = psycopg2.connect(host=dbHost, port=dbPort, dbname=dbName, user=dbUser, password=dbUserPassword)
        db_connection.autocommit = True

    @staticmethod
    def _cleanup():
        global db_connection
        LogWeaver._flush_log()
        db_connection.close()

    @staticmethod
    def set_db_log_frequency(logFrequencyInSeconds):
        global db_log_frequency_in_seconds
        db_log_frequency_in_seconds = logFrequencyInSeconds

    @staticmethod
    def _do_periodic_logging():
        global db_log_frequency_in_seconds
        while True:
            LogWeaver._flush_log()
            time.sleep(db_log_frequency_in_seconds)

    @staticmethod
    def _flush_log():
        global log_queue
        def dbOp(cursor):
            while not log_queue.empty():   
                log_message = log_queue.get_nowait()
                sql = "INSERT INTO log (run_number, application_name, open_clone_log, timestamp, message, tags, level, machine_name, ip_address) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)"
                cursor.execute(sql, (log_message['run_number'], log_message['application_name'], log_message['open_clone_log'], log_message['timestamp'], log_message['message'], log_message['tags'], log_message['level'], log_message['machine_name'], log_message['ip_address'],))
        LogWeaver.get_cursor(dbOp)

class Tags: # TODO: get rid of this
    viewport_streamer = "viewport_streamer"

def InitializeLogWeaver(dbHost,dbPort,dbName,dbUser,dbUserPassword):
    global db_connection
    global db_log_frequency_in_seconds
    global log_queue
    global log_thread
    
    # database connection
    db_connection = None
    LogWeaver.init_db(dbHost,dbPort,dbName,dbUser,dbUserPassword)
    # polling/update database thrad
    db_log_frequency_in_seconds = 1
    log_queue = queue.Queue()
    log_thread = threading.Thread(target=LogWeaver._do_periodic_logging, daemon=True)
    log_thread.start()
    # close database on exit
    atexit.register(LogWeaver._cleanup)