from flask import Flask, request, jsonify
import GlobalVariables
from LogWeaver import LogWeaver
import json
import traceback
import Image_PostProcesser

#################################################################################
############### IMPORT U-2-NET ##################################################
#################################################################################

import sys
import os

# Add the directory of the module to the system path
sys.path.append(os.path.join(os.path.dirname(__file__), 'U-2-Net'))

from u2net_human_seg import process_image

#################################################################################
############### INITILIZATION ###################################################
#################################################################################

GlobalVariables.applicationLog.log("Starting U-2-Net - TODO - ADD FLAG TO DISABLE LOGGING")
app = Flask(__name__)

#################################################################################
############### DEEPFAKE IMAGE GENERATION #######################################
#################################################################################

def removeBackground(sourceImagePath, outputImagePath, threshold = 200):
    sourceImagePath = sourceImagePath[1:] if sourceImagePath.startswith('/') else sourceImagePath
    outputImagePath = outputImagePath[1:] if outputImagePath.startswith('/') else outputImagePath
    sourceImagePath = os.path.join(os.getenv("OpenClone_OpenCloneFS"), sourceImagePath)
    outputImagePath = os.path.join(os.getenv("OpenClone_OpenCloneFS"), outputImagePath)
    GlobalVariables.applicationLog.log("GENERATING BACKGROUND REMOVAL MASK\nsourceImagePath: " + sourceImagePath + "\noutputImagePath: " + outputImagePath + "\nthreshold: " + str(threshold))
    process_image(sourceImagePath, outputImagePath)
    GlobalVariables.applicationLog.log("GENERATED BACKGROUND REMOVAL MASK\nsourceImagePath: " + sourceImagePath + "\noutputImagePath: " + outputImagePath)
    Image_PostProcesser.apply_portrait_mask(sourceImagePath, outputImagePath, threshold)
    GlobalVariables.applicationLog.log("BACKGROUND REMOVED\nsourceImagePath: " + sourceImagePath + "\noutputImagePath: " + outputImagePath)

#################################################################################
############### API #############################################################
#################################################################################

@app.route('/remove-background', methods=['POST'])
def remove_background():
    return handleRequest(request, removeBackground)

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