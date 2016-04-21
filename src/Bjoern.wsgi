import bjoern
from app import application

bjoern.run(
    wsgi_app=application,
    host='0.0.0.0',
    port=9808,
    reuse_port=True
)
