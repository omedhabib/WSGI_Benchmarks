#!/usr/bin/env bash

PROCESSOR_COUNT=$(nproc)
UWSGI_PROCESSES_COUNT=$(( PROCESSOR_COUNT * 2 + 1 ))

uwsgi --http11 :9808 --wsgi-file app.py --master --processes "$UWSGI_PROCESSES_COUNT" --thunder-lock --disable-logging
