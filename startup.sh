#!/bin/bash


DHP=/etc/ssl/private/dhparams.pem
if [ -f "$DHP" ]; then
  echo "DHParams already set"
else
  echo "Setting DHParams"
  mkdir -p /etc/ssl/private && chmod 710 /etc/ssl/private && cd /etc/ssl/private && openssl dhparam -out dhparams.pem 2048 && chmod 600 dhparams.pem
fi

echo "Starting Apache"
chown www-data:www-data /var/www/html -R

apache2-foreground