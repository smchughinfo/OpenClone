from flask import Flask, render_template, request, jsonify, send_from_directory
from traceback import format_exc
import json
import datetime
from ansi2html import Ansi2HTMLConverter
import html
import os
import argparse

#############################################################
###### SET ENVIRONMENT ######################################
#############################################################

parser = argparse.ArgumentParser(description='Run the Flask app with specified environment')
parser.add_argument('--environment', type=str, choices=['local', 'remote', 'kind'], default='local',
                    help='Specify the environment to use (local, remote, or kind)')
args = parser.parse_args()

os.environ['OPENCLONE_ENVIRONMENT'] = args.environment

#############################################################
###### IMPORT GLOBAL VARIABLES AND ITS DEPENDENTS ###########
#############################################################

import GlobalVariables
from Data import Data

#############################################################
###### ENDPOINTS ############################################
#############################################################

app = Flask(__name__)
data = Data()

#############################################################
###### ENDPOINTS ############################################
#############################################################

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/get-log-ids', methods=["POST"])
def get_log_ids():
    def operation():
        # Retrieve data from the request body as JSON
        query_params = request.json

        logIds = data.getLogIds(query_params)
        return jsonify({
            "logIds": logIds
        })

    return doEndpoint(operation)

@app.route('/get-logs', methods=["POST"])
def get_logs():
    def operation():
        # Retrieve data from the request body as JSON
        query_params = request.json

        logs = data.getLogs(query_params)
        formatLogs(logs)
        return jsonify({
            "logs": logs
        })

    return doEndpoint(operation)

#############################################################
###### HELPERS ##############################################
#############################################################

def formatLogs(logs):    
    ansi2HTMLConverter = Ansi2HTMLConverter(inline=True)
    for log in logs:
        log['timestamp'] = log['timestamp'].strftime("%Y-%m-%dT%H:%M:%S.%f")[:-3] # Truncate to milliseconds
       
        if 'img' in log['message']:
            print('FOUND IT')
        log['message'] = ansi2HTMLConverter.convert(log['message'], full=False)
        log['message'] = html.unescape(log['message']).replace("\n", "<br/>")
        print('12')

def doEndpoint(op):
    try:
        return op()
    except Exception as e:
        error_info = {
            "error_message": str(e),
            "error_type": type(e).__name__,
            "traceback": format_exc()
        }
        return jsonify(error_info), 500

#############################################################
###### MAIN #################################################
#############################################################

@app.route(f'/OpenCloneFS/<path:filename>')
def custom_static(filename):
    return send_from_directory(os.getenv("OpenClone_OpenCloneFS"), filename)

if __name__ == '__main__':
    app.run(debug=True, port=1234, use_reloader=False) # TODO: cant use this in prod!!!!!!!
