FROM debian:8.0

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get -y upgrade
RUN apt-get -y install initscripts tar wget \
build-essential autoconf automake libtool pkg-config bison flex valgrind \
libjansson-dev libxml2-dev libsqlite3-dev libical-dev libsasl2-dev libssl-dev libopendkim-dev libcunit1-dev libpcre3-dev uuid-dev libdb5.3-dev

ENV container=docker

RUN cd && wget https://github.com/cyrusimap/cyrus-imapd/archive/cyrus-imapd-2.5.3.tar.gz && tar -xvf cyrus-imapd-2.5.3.tar.gz 

WORKDIR /root/cyrus-imapd-cyrus-imapd-2.5.3 

RUN autoreconf -i -s && ./configure CFLAGS="-W -Wno-unused-parameter -g -O0 -Wall -Wextra -Werror -fPIC" \
--enable-coverage --enable-calalarmd --enable-apple-push-service --enable-autocreate \
--enable-nntp --enable-http \
--enable-replication --with-openssl=yes --enable-nntp --enable-murder \
--enable-idled --enable-event-notification --enable-sieve 

RUN make lex-fix

RUN make

RUN make check

# optional if you're just developing on this machine 
RUN make PREFIX=/usr install  

RUN apt-get update && apt-get -y upgrade
RUN apt-get install -y transfig uuid-dev vim wamerican xutils-dev zlib1g-dev sasl2-bin rsyslog sudo acl telnet

RUN make all CFLAGS=-O

RUN useradd -c "Cyrus IMAP Server" -d /var/lib/imap -g mail -s /bin/bash -r cyrus

RUN groupadd -r saslauth
RUN usermod -aG saslauth cyrus

#It needs to change some information of saslauthd file: START=yes and MECHANISMS="sasldb"
ADD saslauthd /etc/default

RUN sudo mkdir -p /var/imap /var/spool/imap
RUN sudo chown cyrus:mail /var/imap /var/spool/imap /etc/sasldb2
RUN sudo chmod 750 /var/imap /var/spool/imap

ADD cyrus.conf /etc/cyrus.conf
ADD imapd.conf /etc/imapd.conf	

COPY startup.sh /root/startup.sh
RUN chmod +x /root/startup.sh

ENTRYPOINT ["/root/startup.sh"]
