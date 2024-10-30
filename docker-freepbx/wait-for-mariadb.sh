#!/bin/bash

until mysql -h "${DBHOST}" -u "${DBUSER}" -p"${DBPASS}" -e "SHOW DATABASES;" > /dev/null 2>&1; do
  echo "Waiting for MariaDB..."
  sleep 3
done