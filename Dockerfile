FROM debian:stretch

RUN cat /etc/apt/sources.list | sed 's/https:\/\/deb.debian/http:\/\/deb.debian/g' | sed 's/http:\/\/deb.debian.org/http:\/\/cdn-fastly.deb.debian.org/g' > /sources.tmp
RUN cp /sources.tmp /etc/apt/sources.list
RUN cat /etc/apt/sources.list #cache busting
RUN apt-get update && apt-get install nano htop git wget build-essential apt-transport-https ca-certificates apt-utils dirmngr -y

RUN wget -O /etc/apt/trusted.gpg.d/apache2.gpg https://packages.sury.org/apache2/apt.gpg
RUN sh -c 'echo "deb https://packages.sury.org/apache2/ stretch main"> /etc/apt/sources.list.d/apache2.list'
RUN apt-get update
RUN echo "deb http://deb.debian.org/debian stretch-backports main" >> /etc/apt/sources.list
RUN apt-get update
RUN apt-get install dirmngr  -y
RUN apt-get -t stretch-backports install libbrotli1 -y
RUN apt-get install apache2 curl -y


RUN a2enmod proxy proxy_fcgi brotli rewrite allowmethods auth_basic auth_digest auth_form cache cache_disk cache_socache deflate env expires filter headers heartbeat heartmonitor http2 include info log_debug mime mime_magic negotiation proxy proxy_http2 ratelimit remoteip request session session_cookie session_crypto session_dbd setenvif speling ssl status unique_id vhost_alias
RUN service apache2 restart && service apache-htcacheclean start

RUN mkdir -p /opt/scripts
COPY ./startup.sh /opt/scripts/startup.sh
COPY ./apache2-foreground /usr/local/bin/apache2-foreground
RUN chmod +x /opt/scripts/startup.sh
RUN chmod +x /usr/local/bin/apache2-foreground

RUN mkdir -p /etc/ssl/private && chmod 710 /etc/ssl/private && cd /etc/ssl/private && rm dhparams.pem -f

RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/*

ENV DB_ENV_MYSQL_ROOT_PASSWORD [blank]

ENTRYPOINT /opt/scripts/startup.sh