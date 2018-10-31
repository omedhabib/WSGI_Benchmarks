#!/usr/bin/env bash

unitd --control unix:/var/run/control.unit.sock
curl -v -X PUT -d @unit.config --unix-socket /var/run/control.unit.sock http://0/config

sleep 3600
