#!/usr/bin/env python3.5

from gevent import monkey
monkey.patch_all()

import logging
import os

from secure_smtpd import ProxyServer

RELAY_HOST=os.environ.get("RELAY_HOST", "172.17.42.1")
RELAY_PORT=int(os.environ.get("RELAY_PORT", 2501))

logging.basicConfig(level=logging.ERROR)

try:
    localaddr = ("0.0.0.0", 25)
    remoteaddr = (RELAY_HOST, RELAY_PORT)
    #TODO: maximum_execution_time=30, process_count=5
    server = ProxyServer(localaddr, remoteaddr)
    server.run()
except KeyboardInterrupt:
    pass
