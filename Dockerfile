FROM thies88/base-alpine

MAINTAINER thies88

# set version label
ARG BUILD_DATE
ARG VERSION
ARG RADARR_RELEASE
LABEL build_version="Alpine-base-mono:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="Thies88"

# environment settings
ARG DEBIAN_FRONTEND="noninteractive"
ENV XDG_CONFIG_HOME="/config/xdg"
ARG RADARR_BRANCH="master"

RUN apk update
RUN apk add --no-cache tar curl jq && \
echo "**** install radarr packages ****" && \
apk add --no-cache libmediainfo && \
echo "**** install radarr ****" && \
 mkdir -p /app/radarr/bin && \
 if [ -z ${RADARR_RELEASE+x} ]; then \
	RADARR_RELEASE=$(curl -sL "https://radarr.servarr.com/v1/update/${RADARR_BRANCH}/changes?os=linux" \
	| jq -r '.[0].version'); \
 fi && \
 curl -o \
	/tmp/radarr.tar.gz -L \
	"https://radarr.servarr.com/v1/update/${RADARR_BRANCH}/updatefile?version=${RADARR_RELEASE}&os=linux&runtime=netcore&arch=x64" && \
 tar ixzf \
	/tmp/radarr.tar.gz -C \
	/app/radarr/bin --strip-components=1 && \
 echo "**** clean up ****" && \
 apk del tar curl && \
 rm -rf \
 	/app/radarr/bin/Radarr.Update \
	/tmp/* \
	/var/lib/apt/lists/* \
	/var/tmp/*

# add local files
COPY /root /

# ports and volumes
EXPOSE 7878
VOLUME /config /downloads /movies
