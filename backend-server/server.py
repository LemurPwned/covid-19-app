
import json 
from flask import Flask
app = Flask(__name__)

@app.route('/getLatestData')
def getLatestData():
    data = {}
    return json.dumps(data)


