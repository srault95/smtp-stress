FROM phusion/baseimage:latest

ENV DEBIAN_FRONTEND=noninteractive

ENV DISABLE_SSH 1
ENV DISABLE_CRON 1

ENV SLIMTA_VERSION 3.2.3

RUN apt-get update \
	&& apt-get upgrade -y \
	&& apt-get install -y --no-install-recommends \
	 python3.5-dev \
	 build-essential \
	 ca-certificates \
	 curl \
	&& curl -k https://bootstrap.pypa.io/get-pip.py | python3.5 - \
	&& pip install gevent "python-slimta==${SLIMTA_VERSION}" \
	&& rm -f /etc/cron.daily/logrotate 

ADD scripts/ /usr/local/bin/

RUN chmod +x /usr/local/bin/* \
	&& mkdir -p /etc/service/smtpd \
	&& ln -sf /usr/local/bin/start.sh /etc/service/smtpd/run

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
	
EXPOSE 25	