#!/bin/sh
set -e

# chown directories
chown -R asterisk:asterisk /etc/asterisk
chown -R asterisk:asterisk /var/lib/asterisk/moh
chown -R asterisk:asterisk /var/lib/asterisk/sounds

# run asterisk
exec /usr/sbin/asterisk -f
