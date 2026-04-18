#!/usr/bin/env python3
# should be located in: /usr/local/bin/

from flask import Flask
from flask import request
import relay 

app = Flask(__name__)
rb = relay.RelayBoard()
relay.SPECIAL_CHARS_IN_REPR_RELAY=True

@app.route('/<name>/<engaged>')
def set_relay(name, engaged):
    for n in name.split(','):
        rb.set(n, engaged)
    return 'OK'

@app.route('/', methods=['GET'])
def serve_homepage():
    result = rb
    return(f"use <code>/heater,light/1</code> to turn it on<br/><textarea style='font-family:monospace;width:90%;height:90%;'>{result}</textarea>",200)

@app.route('/btns', methods=['GET'])
def serve_buttons():
    return rb.html()

@app.route('/nmap', methods=['GET'])
def serve_nmap():
    with open("/run/netstats/nmap.txt", "r") as f:
        content = f.read()
    return content

if __name__ == '__main__':
  app.run(debug=True, port=80, host='::')
