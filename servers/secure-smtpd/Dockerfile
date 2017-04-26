FROM phusion/baseimage:latest

ENV DEBIAN_FRONTEND=noninteractive

ENV DISABLE_SSH 1
ENV DISABLE_CRON 1

ENV BRANCH master
ENV GEVENT false

RUN apt-get update \
	&& apt-get upgrade -y \
	&& apt-get install -y --no-install-recommends \
	 ca-certificates \
	 curl \
	 git \
	&& curl -k https://bootstrap.pypa.io/get-pip.py | python3.5 - \
	&& rm -f /etc/cron.daily/logrotate 

ADD scripts/ /usr/local/bin/

RUN chmod +x /usr/local/bin/* \
	&& pip install gevent \
	&& pip install -e git+git://github.com/bcoe/secure-smtpd@${BRANCH}#egg=secure-smtpd \
	&& mkdir -p /etc/service/smtpd \
	&& ln -sf /usr/local/bin/start.sh /etc/service/smtpd/run

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
	
EXPOSE 25	