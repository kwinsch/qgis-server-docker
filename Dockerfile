ARG UBUNTU_VERSION=noble
FROM ubuntu:${UBUNTU_VERSION}

ARG QGIS_TRACK=lr
ARG UBUNTU_CODENAME=noble

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get upgrade -y

RUN apt-get install -y gnupg wget software-properties-common ca-certificates && \
    mkdir -m755 -p /etc/apt/keyrings && \
    wget -qO /etc/apt/keyrings/qgis-archive-keyring.gpg \
        https://download.qgis.org/downloads/qgis-archive-keyring.gpg

RUN case "${QGIS_TRACK}" in \
        ltr) REPO_URL="https://qgis.org/ubuntu-ltr" ;; \
        lr)  REPO_URL="https://qgis.org/ubuntu" ;; \
        dev) REPO_URL="https://qgis.org/ubuntu-nightly" ;; \
        *)   echo "Unknown track: ${QGIS_TRACK}" && exit 1 ;; \
    esac && \
    printf 'Types: deb\nURIs: %s\nSuites: %s\nArchitectures: amd64\nComponents: main\nSigned-By: /etc/apt/keyrings/qgis-archive-keyring.gpg\n' \
        "$REPO_URL" "${UBUNTU_CODENAME}" > /etc/apt/sources.list.d/qgis.sources

RUN rm -f /var/lib/apt/lists/*_* && \
    apt-get update && \
    apt-get --fix-broken install -y

RUN apt-get install -y \
    qgis-server \
    python3-qgis \
    xvfb \
    nginx \
    supervisor

RUN apt-get autoremove -y && \
    apt-get autoclean -y && \
    rm -rf /var/lib/apt/lists/*

COPY conf/supervisord/qgis-server.conf /usr/local/etc/qgis-server.conf
COPY conf/nginx/nginx.conf /usr/local/etc/nginx/nginx.conf

RUN rm -f /etc/nginx/sites-enabled/default

COPY conf/start.sh /usr/local/bin/start.sh
RUN chmod 755 /usr/local/bin/start.sh

LABEL org.opencontainers.image.title="QGIS Server" \
      qgis.track="${QGIS_TRACK}"

VOLUME /var/local/qgis

CMD ["/usr/local/bin/start.sh"]
