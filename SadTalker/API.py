from flask import Flask, request, jsonify
import GlobalVariables
from LogWeaver import LogWeaver
import json
import traceback


#################################################################################
############### IMPORT SADTALKER ################################################
#################################################################################

import sys
import os

# Add the directory of the module to the system path
sys.path.append(os.path.join(os.path.dirname(__file__), 'SadTalker'))
from SadTalker import inference

#################################################################################
############### INITILIZATION ###################################################
#################################################################################

GlobalVariables.applicationLog.log("Starting SadTalker - NOTE - PASS IN FLAG TO ENABLE/DISABLE LOGGING")
GlobalVariables.applicationLog.log("⚠️⚠️⚠️ ATTENTION! IF IT TRIES USING AN AUDIO FILE PATH THAT YOU ARE NOT SUPPLYING AS A PARAMETER TO THE HTTP POST /generate-deepfake endpoint IT MAY BE 'STUCK'. THAT IS THE PREVIOUS RUN NEVER FINISHED AND SUBSEQUENT RUNS WILL TRY TO USE THE SAME CACHE AND THEN FAIL. DELETE SADTALKER_CACHE FOR THIS CLONE AND YOU SHOULD SEE IT START USING THE RIGHT AUDIO FILE PATH ⚠️⚠️⚠️")
app = Flask(__name__)

#################################################################################
############### DEEPFAKE IMAGE GENERATION #######################################
#################################################################################

def generateDeepfake(imagePath, audioPath, m3u8Path = None, mp4Path = None, removeAudioFromMp4 = False, cpu = 0, tsSegmentLength=5):
    imagePath = getPath(imagePath)
    audioPath = getPath(audioPath)

    if m3u8Path is None and mp4Path is None:
        raise "either m3u8Path or mp4Path must be specified"

    if m3u8Path is not None:
        m3u8Path = getPath(m3u8Path)
    if mp4Path is not None:
        mp4Path = getPath(mp4Path)

    return inference.generate_deepfake(imagePath, audioPath, m3u8Path, mp4Path, removeAudioFromMp4, cpu, tsSegmentLength)

def getPath(inPath):
    inPath = inPath[1:] if inPath.startswith('/') else inPath
    inPath = os.path.join(GlobalVariables.openclone_fs_path, inPath)
    return inPath

#################################################################################
############### API #############################################################
#################################################################################

@app.route('/generate-deepfake', methods=['POST'])
def generate_deepfake():
    return handleRequest(request, generateDeepfake)

#################################################################################
############### API UTILITY #####################################################
#################################################################################

def handleRequest(request, functionToRun):
    try:
        GlobalVariables.applicationLog.log(f"Requesting {request.base_url} with {json.dumps(request.json)}")

        result = functionToRun(**request.json)

        return jsonify({
                    "result": result,
                }), 200
    except Exception as e:
        errorString = str(e)
        traceback_str = traceback.format_exc()
        GlobalVariables.applicationLog.log(f"Error: {errorString}\nTraceback:\n{traceback_str}", LogWeaver.ERROR)
        return jsonify({"error": errorString}), 500

if __name__ == '__main__':
    app.run(debug=True, host="0.0.0.0", port=GlobalVariables.apiPort, use_reloader=False)
    #app.run(debug=True, host="207.246.82.52", port=GlobalVariables.apiPort, use_reloader=False)