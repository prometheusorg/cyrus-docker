#!/bin/bash

chmod 755 /var/run/saslauthd 

/etc/init.d/saslauthd start

#echo 'imapuser'|saslpasswd2 -u test -p -c password
echo 'cyrus'|saslpasswd2 -u test -p -c cyrus
echo 'bob'|saslpasswd2 -u test -c bob -p
echo 'alice'|saslpasswd2 -u test -c alice -p

chown cyrus /etc/sasldb2*

#chown -R cyrus:mail /var/spool/imap /var/imap

/usr/local/cyrus/bin/master
