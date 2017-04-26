====================
SMTP Stress platform
====================

.. contents:: **Table of Contents**

Required
--------

- Docker 1.11.0+
- Docker-compose 1.7.1+

QuickStart with docker-compose
------------------------------

.. code-block:: bash


   $ git clone https://github.com/srault95/smtp-stress.git
   $ cd smtp-stress
   
   $ docker-compose pull
   $ docker-compose build
   
   $ docker-compose up -d relay
   # Go to http://YOUR_PUBLIC_IP:8025/
   # Defaut login/pass: admin/admin
   # Or: curl -v http://admin:admin@YOUR_PUBLIC_IP:8025/api/v2/messages

Test Postfix (C)
----------------

:mta: http://www.postfix.org
:language: C

.. code-block:: bash
   
   $ docker-compose up -d postfix
   $ docker-compose run --rm client sendmail -H postfix -P 25 -O pprint
   $ docker-compose stop postfix

View logs
:::::::::

.. code-block:: bash

   $ docker-compose exec postfix cat /var/log/mail.log
   $ docker-compose exec syslog cat /var/log/syslog-ng/postfix/postfix.log
   
TODO
::::

- Disable dns resolv  

Test Slimta (python)
--------------------

:mta: https://github.com/slimta/python-slimta
:language: Python with Gevent Framework

.. code-block:: bash
   
   $ docker-compose up -d slimta
   $ docker-compose run --rm client sendmail -H slimta -P 25 -O pprint
   $ docker-compose stop slimta
   
Test secure-smtpd (python)
--------------------------

:mta: https://github.com/bcoe/secure-smtpd
:language: Python standard lib

.. code-block:: bash
   
   $ docker-compose up -d securesmtpd
   $ docker-compose run --rm client sendmail -H securesmtpd -P 25 -O pprint
   $ docker-compose stop securesmtpd

Test secure-smtpd + gevent (python)
-----------------------------------

:mta: https://github.com/bcoe/secure-smtpd
:language: Python standard lib with Gevent monkey patch

.. code-block:: bash
   
   $ docker-compose up -d securesmtpdgevent
   $ docker-compose run --rm client sendmail -H securesmtpdgevent -P 25 -O pprint
   $ docker-compose stop securesmtpdgevent

SMTP Client test options
------------------------

Help
::::

.. code-block:: bash
   
   $ docker-compose run --rm client sendmail --help

   # After test if export json option:
   $ find ./volumes/shared

Basic Tests - One Mail - No concurrency
:::::::::::::::::::::::::::::::::::::::

.. code-block:: bash
   
   $ docker-compose run --rm client sendmail -H postfix -P 25 -O pprint
   $ docker-compose run --rm client sendmail -H slimta -P 25 -O json --json-result /stress/shared/slimta-mails.json

Concurrency Tests
:::::::::::::::::

- 1000 mails per 50 with gevent

.. code-block:: bash
   
   $ docker-compose run --rm client sendmail -H postfix -P 25 -B gevent --count 1000 --parallel 50 -O pprint
   
- 1000 mails per 50 with futures

.. code-block:: bash
   
   $ docker-compose run --rm client sendmail -H postfix -P 25 -B futures --count 1000 --parallel 50 -O pprint
   
Clean all images and containers
-------------------------------

.. code-block:: bash
   
   $ docker-compose down --rmi local -v

