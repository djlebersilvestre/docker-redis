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
COPY provision-steps/usrgrp.sh /steps/usrgrp.sh
RUN /steps/usrgrp.sh

# Install basic packages
COPY provision-steps/packages.sh /steps/packages.sh
RUN /steps/packages.sh

# Install redis 2.8.19
COPY provision-steps/install.sh /steps/install.sh
RUN /steps/install.sh
RUN rm -rf /var/lib/apt/lists/*

# Configure Redis (default data dir and maxmemory at 50Mb)
COPY provision-steps/setup.sh /steps/setup.sh
RUN /steps/setup.sh /data/redis 52428800 testing

# Setup process monitoring through daemontools
COPY provision-steps/svscanboot.sh /steps/svscanboot.sh
RUN /steps/svscanboot.sh /data/redis

# Directory that stores Redis data
VOLUME /data/redis
WORKDIR /data/redis

EXPOSE 6379
CMD [ "svscanboot" ]
