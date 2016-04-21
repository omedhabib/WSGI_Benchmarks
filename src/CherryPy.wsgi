import socket
from cherrypy import wsgiserver
from app import application

server = wsgiserver.CherryPyWSGIServer(
    bind_addr=('0.0.0.0', 9808),
    wsgi_app=application,
    request_queue_size=500,
    server_name=socket.gethostname()
)

if __name__ == '__main__':
    try:
        server.start()
    except KeyboardInterrupt:
        pass
    finally:
        server.stop()
