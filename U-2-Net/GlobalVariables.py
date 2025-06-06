import os
import socket
import sys

machine_name = socket.gethostname()
computerName = socket.gethostname()

server_ip_address = ip_address = (lambda s: (s.connect(("8.8.8.8", 80)), s.getsockname()[0], s.close())[1])(socket.socket(socket.AF_INET, socket.SOCK_DGRAM))
apiPort = 5002

# LOGGING
from LogWeaver import LogWeaver, InitializeLogWeaver
log_ip = os.getenv('OpenClone_DB_Host')
InitializeLogWeaver(log_ip, os.getenv("OpenClone_DB_Port"), os.getenv("OpenClone_LogDB_Name"), os.getenv("OpenClone_LogDB_User"), os.getenv("OpenClone_LogDB_Password"))
applicationLog = LogWeaver("U-2-Net", server_ip_address, level=LogWeaver.INFO, loggerName="U-2-Net")
applicationLog.increment_run_number()