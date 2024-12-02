# Use debian unstable-slim as base image
FROM debian:unstable-slim

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Update base system
RUN apt update && apt upgrade -y

# Install QGIS repository key
RUN apt install -y wget && \
    wget -O /etc/apt/keyrings/qgis-archive-keyring.gpg https://download.qgis.org/downloads/qgis-archive-keyring.gpg && \
    apt purge -y wget

# Add QGIS repository configuration
COPY conf/apt/qgis.sources /etc/apt/sources.list.d/qgis.sources

# Install required packages
RUN apt update && \
    apt install -y \
    qgis-server \
    nginx \
    supervisor && \
    rm -rf /var/lib/apt/lists/*

# Copy supervisord configuration
COPY conf/supervisord/qgis-server.conf /usr/local/etc/qgis-server.conf
COPY conf/nginx/nginx.conf /usr/local/etc/nginx/nginx.conf

# Remove default nginx config
RUN rm -f /etc/nginx/sites-enabled/default

# Copy and setup start script
COPY conf/start.sh /usr/local/bin/start.sh
RUN chmod 755 /usr/local/bin/start.sh

# Define volume for persistent data
VOLUME /var/local/qgis

# Start script as entrypoint
CMD ["/usr/local/bin/start.sh"]
