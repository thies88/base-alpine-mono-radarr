FROM thies88/base-alpine-mono

MAINTAINER thies88

# set version label
ARG BUILD_DATE
ARG VERSION
ARG RADARR_RELEASE
LABEL build_version="Alpine-base-mono:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="Thies88"

# environment settings
ENV XDG_CONFIG_HOME="/config/xdg"

RUN apk update
RUN apk add --no-cache tar curl jq && \
echo "**** install radarr packages ****" && \
apk add --no-cache libmediainfo && \
echo "**** install radarr ****" && \
 if [ -z ${RADARR_RELEASE+x} ]; then \
	RADARR_RELEASE=$(curl -sX GET "https://api.github.com/repos/Radarr/Radarr/releases" \
	| jq -r '.[0] | .tag_name'); \
 fi && \
 radarr_url=$(curl -s https://api.github.com/repos/Radarr/Radarr/releases/tags/"${RADARR_RELEASE}" \
	|jq -r '.assets[].browser_download_url' |grep linux) && \
 mkdir -p \
	/opt/radarr && \
 curl -o \
 /tmp/radar.tar.gz -L \
	"${radarr_url}" && \
 tar xzf \
 /tmp/radar.tar.gz -C \
	/opt/radarr --strip-components=1 && \
 echo "**** clean up ****" && \
 apk del tar curl && \
 rm -rf \
	/tmp/* \
	/var/lib/apt/lists/* \
	/var/tmp/*

# add local files
COPY /root /

# ports and volumes
EXPOSE 7878
VOLUME /config /downloads /movies
