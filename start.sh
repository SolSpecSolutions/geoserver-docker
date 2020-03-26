#!/bin/bash

# Check for Existance of geoserver install, if not then move into place
if [ ! -d ${GEOSERVER_DATA_DIR} ]; then
    cp -Rp ${GEOSERVER_DATA_DIR}-install ${GEOSERVER_DATA_DIR}
    cp -Rp ${GEOSERVER_EXT_DIR}-install ${GEOSERVER_EXT_DIR}
fi

if [ -n "${CUSTOM_UID}" ]; then
    echo "Using custom UID ${CUSTOM_UID}."
    usermod -u ${CUSTOM_UID} tomcat
    find / -user 1099 -exec chown -h tomcat {} \;
fi

if [ -n "${CUSTOM_GID}" ]; then
    echo "Using custom GID ${CUSTOM_GID}."
    groupmod -g ${CUSTOM_GID} tomcat
    find / -group 1099 -exec chgrp -h tomcat {} \;
fi

# We need this line to ensure that data has the correct rights
chown -R tomcat:tomcat ${GEOSERVER_DATA_DIR}
chown -R tomcat:tomcat ${GEOSERVER_EXT_DIR}

for ext in `ls -d "${GEOSERVER_EXT_DIR}"/*/`; do
    su tomcat -c "cp "${ext}"*.jar /usr/local/geoserver/WEB-INF/lib"
done

timeout 20s su tomcat -c "/usr/local/tomcat/bin/catalina.sh run"
pkill -u tomcat

/usr/bin/python /user/local/bin/keycloak_config.py
sleep 10
su tomcat -c "/usr/local/tomcat/bin/catalina.sh run"


