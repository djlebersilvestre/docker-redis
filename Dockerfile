###############################################################
## Dockerfile to build a Debian 7.4 - Redis image based on   ##
## Cloud at Cost machine. Base script extracted from:        ##
## https://github.com/docker-library/redis/tree/master/2.8   ##
###############################################################

# Pull base image
FROM debian:7.4
MAINTAINER Daniel Silvestre (djlebersilvestre@github.com)

# Add redis user and group first to make sure their IDs get assigned
# consistently, regardless of whatever dependencies get added
RUN groupadd -r redis && useradd -r -g redis redis

# Install basic packages and clean apt when done
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y curl
RUN apt-get install -y pwgen
RUN apt-get install -y procps
RUN apt-get install -y daemontools
RUN rm -rf /var/lib/apt/lists/*

# Grab gosu for easy step-down from root
RUN gpg --keyserver pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4
RUN curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture)" \
	&& curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture).asc" \
	&& gpg --verify /usr/local/bin/gosu.asc \
	&& rm /usr/local/bin/gosu.asc \
	&& chmod +x /usr/local/bin/gosu

# Install redis
ENV REDIS_VERSION 2.8.19
ENV REDIS_DOWNLOAD_URL http://download.redis.io/releases/redis-2.8.19.tar.gz
ENV REDIS_DOWNLOAD_SHA1 3e362f4770ac2fdbdce58a5aa951c1967e0facc8

RUN buildDeps='gcc libc6-dev make'; \
	set -x \
	&& apt-get update && apt-get install -y $buildDeps --no-install-recommends \
	&& rm -rf /var/lib/apt/lists/* \
	&& mkdir -p /usr/src/redis \
	&& curl -sSL "$REDIS_DOWNLOAD_URL" -o redis.tar.gz \
	&& echo "$REDIS_DOWNLOAD_SHA1 *redis.tar.gz" | sha1sum -c - \
	&& tar -xzf redis.tar.gz -C /usr/src/redis --strip-components=1 \
	&& rm redis.tar.gz \
	&& make -C /usr/src/redis \
	&& make -C /usr/src/redis install \
	&& rm -r /usr/src/redis \
	&& apt-get purge -y --auto-remove $buildDeps

# Directory that stores Redis data
RUN mkdir -p /data/redis
RUN chown redis:redis /data/redis
VOLUME /data/redis
WORKDIR /data/redis

# Maximum memory reserved for Redis in BYTES
ENV REDIS_MAXMEM 52428800
ENV REDIS_CONF_DIR /usr/local/etc/redis
ENV REDIS_CONF $REDIS_CONF_DIR/redis.conf

# Configure redis
RUN mkdir -p $REDIS_CONF_DIR
RUN curl -sSL "http://download.redis.io/redis-stable/redis.conf" -o $REDIS_CONF
RUN sed -i -e "s/^# requirepass foobared/requirepass $(pwgen -s -1 16)/" $REDIS_CONF
RUN sed -i -e "s/^timeout 0/timeout 120/" $REDIS_CONF
RUN sed -i -e "s/^tcp-keepalive 0/tcp-keepalive 60/" $REDIS_CONF
RUN sed -i -e 's/^logfile ""/logfile "\/var\/log\/redis.log"/' $REDIS_CONF
RUN sed -i -e "s/^databases 16/databases 3/" $REDIS_CONF
RUN sed -i -e "s/^dir .\//dir \/data\/redis/" $REDIS_CONF
RUN sed -i -e "s/^# maxmemory <bytes>/maxmemory $REDIS_MAXMEM/" $REDIS_CONF
RUN echo "REDIS_PASSWORD: $(grep '^requirepass \w\+' $REDIS_CONF | awk '{print $2}')"

# Setup process monitoring through daemontools
RUN mkdir -p /etc/service/redis
RUN echo "#!/bin/bash\nredis-server /usr/local/etc/redis/redis.conf" > /etc/service/redis/run
RUN chmod +x /etc/service/redis/run
RUN echo "\nSV:123456:respawn:/usr/bin/svscanboot" >> /etc/inittab

COPY docker-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 6379
CMD [ "svscanboot" ]
