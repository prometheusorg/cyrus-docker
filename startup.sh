#!/bin/bash

/etc/init.d/saslauthd start

echo 'cyrus'|saslpasswd2 -u test -p -c cyrus
echo 'bob'|saslpasswd2 -u test -c bob -p
echo 'alice'|saslpasswd2 -u test -c alice -p

chown -R cyrus:mail /var/spool/imap /var/imap

/usr/local/cyrus/bin/master
