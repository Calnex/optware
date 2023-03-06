from os import curdir, sep
from os.path import join as pjoin

import ssl
from http.server import BaseHTTPRequestHandler, HTTPServer

class StoreHandler(BaseHTTPRequestHandler):

    def do_GET(self):
        with open('/var/www/loading.html') as fh:
            self.send_response(200)
            self.send_header('Content-type', 'text/html')
            self.end_headers()
            self.wfile.write(fh.read().encode())


# Create an HTTPS server on port 443
https_server = HTTPServer(('', 443), StoreHandler)
https_server.socket = ssl.wrap_socket(https_server.socket, certfile='/home/calnex/Certificates/hold.pem', keyfile='/home/calnex/Certificates/hold.pem', server_side=True)
https_server.serve_forever()