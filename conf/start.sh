#!/bin/sh

set -e

# Required directories under /var/local/qgis
REQUIRED_DIRS="log run projects etc projects/opendata"

# Check and create required directories
for dir in ${REQUIRED_DIRS}; do
    if [ ! -d "/var/local/qgis/${dir}" ]; then
        echo "Creating directory /var/local/qgis/${dir}"
        mkdir -p "/var/local/qgis/${dir}"
        
        # Set etc directory to root ownership
        if [ "${dir}" = "etc" ]; then
            chown root:root "/var/local/qgis/${dir}"
            chmod 755 "/var/local/qgis/${dir}"
        else
            chown www-data:www-data "/var/local/qgis/${dir}"
            chmod 755 "/var/local/qgis/${dir}"
        fi
    fi
done

# Create QGIS auth db directory
mkdir -p /var/local/qgis/etc/qgis
chown www-data:www-data /var/local/qgis/etc/qgis
chmod 700 /var/local/qgis/etc/qgis

# Set ownership for existing content
# Projects directory and contents to www-data
chown -R www-data:www-data /var/local/qgis/projects
chmod -R 755 /var/local/qgis/projects

# Log directory to www-data
chown -R www-data:www-data /var/local/qgis/log
chmod -R 755 /var/local/qgis/log

# Run dir's
mkdir -p /var/run/nginx
chown www-data:www-data /run/nginx
chmod 755 /var/run/nginx

mkdir -p /var/run/qgis
chown www-data:www-data /run/qgis
chmod 755 /var/run/qgis

# Execute supervisord with explicit config
exec /usr/bin/supervisord -n -c /usr/local/etc/qgis-server.conf
