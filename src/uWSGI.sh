#!/usr/bin/env bash

# The official documentation doesn't have any word on this,
# but this seems to be a common practice
PROCESSOR_COUNT=$(nproc)
THREAD_COUNT=2
UWSGI_PROCESSES_COUNT=$(( PROCESSOR_COUNT * 2 + 1 ))
# We don't have any static content and we don't have any
# security concerns for this benchmark, so we'll be using
# bare uWSGI (without nginx)
# http://serverfault.com/questions/590819/why-do-i-need-nginx-when-i-have-uwsgi

uwsgi --http11 :9808 --wsgi-file app.py --master --processes "$UWSGI_PROCESSES_COUNT" --threads "$THREAD_COUNT" --thunder-lock --enable-threads --disable-logging
