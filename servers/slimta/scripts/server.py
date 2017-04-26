#!/usr/bin/env python3.5

import logging
import os

from slimta.edge.smtp import SmtpEdge
from slimta.queue import Queue
from slimta.queue.dict import DictStorage
from slimta.relay.smtp.static import StaticSmtpRelay
from slimta.policy.headers import *
from slimta.policy.split import RecipientDomainSplit

RELAY_HOST=os.environ.get("RELAY_HOST", "172.17.42.1")
RELAY_PORT=int(os.environ.get("RELAY_PORT", 2501))

logging.basicConfig(level=logging.DEBUG)

# Set up outbound delivery by MX lookup.
relay = StaticSmtpRelay(host=RELAY_HOST, port=RELAY_PORT)

# Set up local queue storage to in-memory dictionaries.
queue_storage = DictStorage({}, {})
queue = Queue(queue_storage, relay)
queue.start()

# Ensure necessary headers are added.
#queue.add_policy(AddDateHeader())
#queue.add_policy(AddMessageIdHeader())
#queue.add_policy(AddReceivedHeader())
#queue.add_policy(RecipientDomainSplit())

# Listen for messages on port 25.
edge = SmtpEdge(('0.0.0.0', 25), queue)
edge.start()
try:
    edge.get()
except KeyboardInterrupt:
    print