import ssl
from http.server import BaseHTTPRequestHandler, HTTPServer

class StoreHandler(BaseHTTPRequestHandler):

    def do_GET(self):
        with open('/var/www/loading.html') as fh:
            self.send_response(200)
            self.send_header('Content-type', 'text/html')
            self.end_headers()
            self.wfile.write(fh.read().encode())

# Create an HTTP server on port 8080
http_server = HTTPServer(('', 8080), StoreHandler)
http_server.serve_forever()

# Create an HTTPS server on port 44301
https_server = HTTPServer(('', 44301), StoreHandler)
https_server.socket = ssl.wrap_socket(https_server.socket, certfile='/home/calnex/Certificates/hold.pem', keyfile='/home/calnex/Certificates/hold.pem', server_side=True)
https_server.serve_forever()
