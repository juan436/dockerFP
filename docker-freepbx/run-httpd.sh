#!/bin/bash

WORKDIR=/usr/local/src/freepbx

if [ ! -f /var/www/html/.pbx ]; then
  # start asterisk
  /usr/sbin/safe_asterisk
  # wait for MariaDB
  /wait-for-mariadb.sh
  # download and install freepbx
  wget -O /usr/local/src/freepbx-17.0-latest-EDGE.tgz http://mirror.freepbx.org/modules/packages/freepbx/freepbx-17.0-latest-EDGE.tgz
  tar zxvf /usr/local/src/freepbx-17.0-latest-EDGE.tgz -C /usr/local/src
  cd ${WORKDIR}
  
  # Install FreePBX
  ./install --dbengine=${DBENGINE} --dbname=${DBNAME} --dbhost=${DBHOST} --dbport=${DBPORT} \
  --cdrdbname=${CDRDBNAME} --dbuser=${DBUSER} --dbpass=${DBPASS} --user=${USER}  --group=${GROUP} \
  --webroot=${WEBROOT} --astetcdir=${ASTETCDIR} --astmoddir=${ASTMODDIR} --astvarlibdir=${ASTVARLIBDIR} \
  --astagidir=${ASTAGIDIR} --astspooldir=${ASTSPOOLDIR} --astrundir=${ASTRUNDIR} --astlogdir=${ASTLOGDIR} \
  --ampbin=${AMPBIN} --ampsbin=${AMPSBIN} --ampcgibin=${AMPCGIBIN}  --ampplayback=${AMPPLAYBACK} -n

  # Verify fwconsole installation
  if [ ! -f /var/lib/asterisk/bin/fwconsole ]; then
      echo "Error: fwconsole no se encuentra después de la instalación."
      exit 1
  fi

  # configure freepbx
  export PATH=$PATH:/usr/sbin:/var/lib/asterisk/bin
  fwconsole ma installall
  fwconsole reload
  fwconsole restart
  touch /var/www/html/.pbx
  mkdir -p /var/lib/asterisk/etc
  cp /etc/freepbx.conf /var/lib/asterisk/etc/
  chown -R asterisk:asterisk /var/lib/asterisk/etc
  # start httpd service
  /usr/sbin/apachectl -DFOREGROUND
else
  # start asterisk
  /usr/sbin/safe_asterisk
  # fix simlinks
  ln -sf /var/lib/asterisk/etc/freepbx.conf /etc/freepbx.conf
  ln -sf /var/lib/asterisk/bin/fwconsole /usr/sbin/fwconsole
  # configure freepbx
  export PATH=$PATH:/usr/sbin:/var/lib/asterisk/bin
  fwconsole reload
  fwconsole restart
  # start httpd service
  /usr/sbin/apachectl -DFOREGROUND
fi