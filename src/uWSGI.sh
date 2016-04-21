#!/usr/bin/env bash

# The official documentation doesn't have any word on this,
# but this seems to be a common practice
PROCESSOR_COUNT=$(nproc)
THREAD_COUNT=2

# We don't have any static content and we don't have any
# security concerns for this benchmark, so we'll be using
# bare uWSGI (without nginx)
# http://serverfault.com/questions/590819/why-do-i-need-nginx-when-i-have-uwsgi

uwsgi --http :9808 --plugin python2 --wsgi-file app.py --processes "$PROCESSOR_COUNT" --threads "$THREAD_COUNT" --disable-logging
