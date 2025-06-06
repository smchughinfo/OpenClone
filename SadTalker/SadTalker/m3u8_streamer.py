import os
import subprocess
import GlobalVariables
import threading
from LogWeaver import LogWeaver
import time

class m3u8Streamer:
    #################################################################################
    ############### CONSTRUCTOR #####################################################
    #################################################################################

    def __init__(self, audioFilePath, m3u8Path, tsSegmentLength):
        self.m3u8Path = m3u8Path
        self.audioFilePath = audioFilePath
        self.framesStreamed = 0
        self.tsSegmentLength = tsSegmentLength
    def __enter__(self):
        # Ensure directory exists
        os.makedirs(os.path.dirname(self.m3u8Path), exist_ok=True)

        # Check for existing m3u8 and ts files and delete them
        self.cleanup_existing_files()

        self.ffmpegProcess = subprocess.Popen(
            [
                'ffmpeg',
                '-y',  # Overwrite output files without asking
                '-f', 'rawvideo',  # Input format,
                '-pixel_format', 'rgb24',  # Input pixel format
                '-video_size', f'256x256',  # Input video size
                '-framerate', '25',  # Input frame rate
                '-i', '-',  # Read input from stdin
                "-i", self.audioFilePath,
                '-c:v', 'libx264',  # Video codec
                '-preset', 'veryfast',  # Encoding preset
                '-tune', 'zerolatency', # Optimizes the encoding for fast decoding by reducing latency introduced by the encoder
                '-hls_time', str(self.tsSegmentLength),  # Segment duration (seconds) set to 15 seconds
                '-force_key_frames', 'expr:gte(t,n_forced*' + str(self.tsSegmentLength) + ')',  # Force key frames to match segment duration
                '-hls_list_size', '0',  # Maximum number of playlist entries (0 means unlimited)
                self.m3u8Path  # Output HLS playlist file
            ], 
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )

        threading.Thread(target=self.log_ffmpeg_output, args=(self.ffmpegProcess, "stdout"), daemon=True).start()
        threading.Thread(target=self.log_ffmpeg_output, args=(self.ffmpegProcess, "stderr"), daemon=True).start()
        return self

    #################################################################################
    ############### DESTRUCTOR ######################################################
    #################################################################################
        
    def __exit__(self, exc_type, exc_value, traceback):
        self.ffmpegProcess.stdin.close()
        self.close_ffmpeg()

    def close_ffmpeg(self):
        GlobalVariables.applicationLog.log(f"Closing ffmpeg with {self.framesStreamed} frames streamed.")
        exit_code = None
        timeout = 30
        check_interval = 1
        elapsed_time = 0
        while exit_code is None and elapsed_time < timeout:
            time.sleep(check_interval)
            elapsed_time += check_interval
            exit_code = self.ffmpegProcess.poll()

        if exit_code is None:
            self.ffmpegProcess.terminate()
            try:
                self.ffmpegProcess.wait(timeout=5)
            except subprocess.TimeoutExpired:
                self.ffmpegProcess.kill()

    #################################################################################
    ############### LOGIC ###########################################################
    #################################################################################
            
    def log_ffmpeg_output(self, process, stream_name):
        stream = getattr(process, stream_name)
        for line in iter(stream.readline, b''):
            logMessage = line.decode()
            GlobalVariables.ffmpegLog.log(logMessage, isThirdParty=True)

    def streamToFFMPEG(self, frame):
        self.ffmpegProcess.stdin.write(frame.tobytes()) # todo this might be faster if you dont convert to pil?
        self.framesStreamed += 1
        fps = 25 # this just comes from SadTalker
        if (self.framesStreamed == 1):
            GlobalVariables.applicationLog.log(f"Streaming frame {self.framesStreamed} to ffmpeg.")
            self.ffmpegProcess.stdin.flush()

    def cleanup_existing_files(self):
        # Remove existing m3u8 file
        if os.path.exists(self.m3u8Path):
            os.remove(self.m3u8Path)

        # Remove associated .ts files
        ts_dir = os.path.dirname(self.m3u8Path)
        for file in os.listdir(ts_dir):
            if file.endswith(".ts"):
                os.remove(os.path.join(ts_dir, file))
