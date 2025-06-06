import os
import subprocess

class AudioRemover:
    #################################################################################
    ############### CONSTRUCTOR #####################################################
    #################################################################################
    
    def __init__(self, videoFilePath):
        self.videoFilePath = videoFilePath

    #################################################################################
    ############### REMOVE AUDIO FUNCTION ###########################################
    #################################################################################

    def remove_audio(self):
        if not os.path.exists(self.videoFilePath):
            raise FileNotFoundError(f"The file {self.videoFilePath} does not exist.")

        tempFilePath = self.videoFilePath + ".temp.mp4"

        # Run ffmpeg command to remove audio
        command = [
            'ffmpeg',
            '-i', self.videoFilePath,  # Input file
            '-c', 'copy',  # Copy video codec
            '-an',  # Remove audio
            tempFilePath  # Output temporary file
        ]
        
        process = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

        # Check for errors
        if process.returncode != 0:
            error_message = process.stderr.decode()
            raise RuntimeError(f"ffmpeg error: {error_message}")

        # Replace the original file with the modified file
        os.replace(tempFilePath, self.videoFilePath)

        print(f"Audio removed successfully from {self.videoFilePath}")
