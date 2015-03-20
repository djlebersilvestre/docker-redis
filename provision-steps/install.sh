#!/bin/bash

buildDeps='gcc libc6-dev make'; \
  set -x \
  && apt-get update && apt-get install -y $buildDeps --no-install-recommends \
  && rm -rf /var/lib/apt/lists/* \
  && mkdir -p /usr/src/redis \
  && curl -sSL "http://download.redis.io/releases/redis-2.8.19.tar.gz" -o redis.tar.gz \
  && echo "3e362f4770ac2fdbdce58a5aa951c1967e0facc8 *redis.tar.gz" | sha1sum -c - \
  && tar -xzf redis.tar.gz -C /usr/src/redis --strip-components=1 \
  && rm redis.tar.gz \
  && make -C /usr/src/redis \
  && make -C /usr/src/redis install \
  && rm -r /usr/src/redis \
  && apt-get purge -y --auto-remove $buildDeps

exit 0
