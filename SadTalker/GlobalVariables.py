import os
import socket
import sys

machine_name = socket.gethostname()
computerName = socket.gethostname()

server_ip_address = ip_address = (lambda s: (s.connect(("8.8.8.8", 80)), s.getsockname()[0], s.close())[1])(socket.socket(socket.AF_INET, socket.SOCK_DGRAM))
apiPort = 5001

openclone_fs_path = os.getenv("OpenClone_OpenCloneFS")

# LOGGING
from LogWeaver import LogWeaver, InitializeLogWeaver
log_ip = os.getenv('OpenClone_DB_Host')
InitializeLogWeaver(log_ip, os.getenv("OpenClone_DB_Port"), os.getenv("OpenClone_LogDB_Name"), os.getenv("OpenClone_LogDB_User"), os.getenv("OpenClone_LogDB_Password"))
applicationLog = LogWeaver("SadTalker", server_ip_address, level=LogWeaver.INFO, loggerName="SadTalker")
ffmpegLog = LogWeaver("ST_FFMPEG", server_ip_address, level=LogWeaver.INFO, loggerName="ST_FFMPEG")
applicationLog.increment_run_number()

os.environ["CUDA_VISIBLE_DEVICES"] = os.getenv("OpenClone_CUDA_VISIBLE_DEVICES") # this allows all of the environment variables to start with OpenClone''