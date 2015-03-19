###############################################################
## Dockerfile to build a Debian 7.4 - Redis image based on   ##
## Cloud at Cost machine. Base script extracted from:        ##
## https://github.com/docker-library/redis/tree/master/2.8   ##
###############################################################

# Pull base image
FROM debian:7.4
MAINTAINER Daniel Silvestre (djlebersilvestre@github.com)

# Base script - all provisioning funcions
COPY provision-redis.sh /provision-redis.sh
RUN chmod +x /provision-redis.sh

# Add redis user and group first to make sure their IDs get assigned
# consistently, regardless of whatever dependencies get added
RUN /provision-redis.sh usrgrp

# Install basic packages
RUN /provision-redis.sh packages

# Install redis 2.8.19
RUN /provision-redis.sh install

# Configure Redis (default data dir and maxmemory at 50Mb)
RUN /provision-redis.sh setup /data/redis 52428800

# Directory that stores Redis data
VOLUME /data/redis
WORKDIR /data/redis

# Setup process monitoring through daemontools
RUN /provision-redis.sh svscanboot /data/redis

EXPOSE 6379
CMD [ "svscanboot" ]
