#!/bin/bash

mkdir -p /etc/postfix/local

postconf compatibility_level=2
postconf smtputf8_enable=no
#If you specify the mynetworks list by hand, Postfix ignores the mynetworks_style setting. 
#postconf mynetworks_style=class

postconf 'smtpd_banner=secure smtp'
postconf "myhostname=${MY_HOSTNAME}"

postconf "append_at_myorigin = no"
postconf "transport_maps = hash:/etc/postfix/local/transport"
postconf "relay_domains = \$mydestination, hash:/etc/postfix/local/relays"
postconf "relay_recipient_maps = hash:/etc/postfix/local/directory"
postconf "mynetworks=cidr:/etc/postfix/local/mynetworks"

postconf "disable_vrfy_command=yes"
#postconf "disable_verp_bounces = no"

if [ -n "${MESSAGE_SIZE_LIMIT}" ]; then
	postconf "message_size_limit = ${MESSAGE_SIZE_LIMIT}"
fi

if [ -n "${BIND_SMTP_TRANSPORT}" ]; then
	postconf "smtp_bind_address = ${BIND_SMTP_TRANSPORT}"
fi

if [ -n "${RELAY_HOST}" ]; then
	postconf "relayhost = [${RELAY_HOST}]:${RELAY_PORT}" 
fi

#postconf 'inet_interfaces = 127.0.0.1'
#mynetworks = 127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128

if [ "${ACTIVE_FILTER}" == "1" ]; then
	if [ -e /etc/postfix/local/filters ]; then
		postconf "smtpd_relay_restrictions = permit_mynetworks, permit_sasl_authenticated, ${ACTIVE_POSTGREY} defer_unauth_destination check_recipient_access hash:/etc/postfix/local/filters"
		postconf "content_filter="
		postmap /etc/postfix/local/filters
	else
		postconf "content_filter = smtp-amavis:[127.0.0.1]:10024"
		postconf "smtpd_relay_restrictions = permit_mynetworks, permit_sasl_authenticated, ${ACTIVE_POSTGREY} defer_unauth_destination"
	fi
fi

[ -e /etc/postfix/local/relays ] || touch /etc/postfix/local/relays
[ -e /etc/postfix/local/directory ] || touch /etc/postfix/local/directory
[ -e /etc/postfix/local/transport ] || touch /etc/postfix/local/transport
[ -e /etc/postfix/local/mynetworks ] || touch /etc/postfix/local/mynetworks

grep ${MY_NETWORK} /etc/postfix/local/mynetworks 2>/dev/null 1>&2 || echo -e "${MY_NETWORK}\t#loopback" >> /etc/postfix/local/mynetworks
grep ${MY_DOMAIN} /etc/postfix/local/relays 2>/dev/null 1>&2 || echo -e "${MY_DOMAIN}\tOK" >> /etc/postfix/local/relays  
grep ${MY_DOMAIN} /etc/postfix/local/directory 2>/dev/null 1>&2 || echo -e "@${MY_DOMAIN}\tOK" >> /etc/postfix/local/directory

grep ${MY_ROOT_EMAIL} /etc/aliases 2>/dev/null 1>&2
RET=$?
if [ "$RET" != "0" ]; then
	echo "postmaster: root"> /etc/aliases 
	echo "root: ${MY_ROOT_EMAIL}" >> /etc/aliases 
	newaliases
fi 

postmap /etc/postfix/local/relays
postmap /etc/postfix/local/directory
postmap /etc/postfix/local/transport
postmap /etc/postfix/local/mynetworks

cd /etc/postfix

/usr/sbin/postfix -c /etc/postfix check 1>&2

exec /usr/lib/postfix/sbin/master -c /etc/postfix -d
