FROM debian:unstable

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Update base system
RUN apt update && apt upgrade -y

# Install QGIS repository key
RUN apt install -y gnupg ca-certificates && \
    gpg --keyserver keyserver.ubuntu.com --recv-keys  0xD155B8E6A419C5BE && \
    gpg --export '0xD155B8E6A419C5BE' > /etc/apt/keyrings/qgis-archive-keyring.gpg && \ 
    apt purge -y gnupg

# Add QGIS repository configuration
COPY conf/apt/qgis.sources /etc/apt/sources.list.d/qgis.sources
#COPY conf/apt/sources.list /etc/apt/sources.list

# Fix broken installs that may happen in unstable
RUN rm /var/lib/apt/lists/*_* && \
    apt update && \
    apt --fix-broken install -y

# Install required packages
RUN apt install -y \
    qgis-server \
    nginx \
    supervisor 

# Clean up
RUN apt autoremove -y && \
    apt autoclean -y && \
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
