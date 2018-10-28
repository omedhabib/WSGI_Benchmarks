#!/usr/bin/env bash

# The author of mod_wsgi calls mod_wsgi-express "a production grade server",
# so we're using that instead of configuring apache
# (http://blog.dscpl.com.au/2015/04/introducing-modwsgi-express.html)

# Like uWSGI, the official documentation doesn't have any word on this,
# so for consistency, we're copying what uWSGI is doing
PROCESSOR_COUNT=$(nproc)
THREAD_COUNT=2
USER=www-data
GROUP=www-data

mod_wsgi-express start-server app.py --port 9808 --processes "$PROCESSOR_COUNT" --threads "$THREAD_COUNT" --user "$USER" --group "$GROUP"
