#!/bin/bash

set -e

if [ "${GEVENT}" == "true"]; then
	exec /usr/local/bin/server-gevent.py
else
	exec /usr/local/bin/server.py
fi
