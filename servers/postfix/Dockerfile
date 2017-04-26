FROM phusion/baseimage:latest

ENV DEBIAN_FRONTEND=noninteractive
ENV MY_HOSTNAME mx.example.org
ENV MY_DOMAIN example.org
ENV MY_ROOT_EMAIL root@example.org
ENV MY_NETWORK 172.17.0.0/16
ENV RELAY_HOST 172.17.42.1
ENV RELAY_PORT 2501
ENV ACTIVE_FILTER 0

ENV DISABLE_SSH 1
ENV DISABLE_CRON 1

RUN echo "postfix postfix/main_mailer_type string 'Internet Site'" | debconf-set-selections
RUN echo "postfix postfix/mailname string mx.example.org" | debconf-set-selections
RUN echo "postfix postfix/root_address string root@example.org" | debconf-set-selections
RUN echo "postfix postfix/mynetworks string 172.17.0.0/16" | debconf-set-selections

RUN apt-get update \
	&& apt-get install -y --no-install-recommends postfix \
	&& rm -f /etc/cron.daily/logrotate

ADD postfix.sh /usr/local/bin

RUN chmod +x /usr/local/bin/postfix.sh \
	&& mkdir -p /etc/service/postfix \
	&& ln -sf /usr/local/bin/postfix.sh /etc/service/postfix/run

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE 25