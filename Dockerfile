ARG ubuntu_dist=noble
FROM ubuntu:${ubuntu_dist}

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Update base system
RUN apt update && apt upgrade -y

# Install QGIS repository key and add repository
RUN apt install -y gnupg wget software-properties-common && \
    wget -qO - https://qgis.org/downloads/qgis-2022.gpg.key | gpg --no-default-keyring --keyring gnupg-ring:/etc/apt/trusted.gpg.d/qgis-archive.gpg --import && \
    chmod a+r /etc/apt/trusted.gpg.d/qgis-archive.gpg && \
    add-apt-repository "deb https://qgis.org/ubuntu ${ubuntu_dist} main" 
    
# Fix broken installs that may happen in unstable
RUN rm /var/lib/apt/lists/*_* && \
    apt update && \
    apt --fix-broken install -y

# Install required packages
RUN apt install -y \
    qgis-server \
    python3-qgis \
    xvfb \
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
