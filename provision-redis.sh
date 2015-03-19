#!/bin/bash

set -e

usrgrp() {
  groupadd -r redis && useradd -r -g redis redis
}

packages() {
  set -x && apt-get update && apt-get upgrade -y \
    && apt-get install -y vim curl pwgen procps screen daemontools
}

install() {
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
}

setup() {
  data_dir=$1
  conf=$1/redis.conf
  maxmem=$2
  passwd=$3

  if [ -z "$data_dir" ]; then
    echo "The Redis data dir must be passed as argument for $0 continue with the setup."
    exit 1
  fi
  if [ -z "$maxmem" ]; then
    echo "The maxmemory (in bytes) must be passed as argument for $0 continue with the setup."
    exit 1
  fi
  if [ -z "$passwd" ]; then
    echo "Password not given. Generating random password."
    passwd=$(pwgen -s -1 16)
  fi

  echo "REDIS_DATA_DIR: $data_dir"
  echo "REDIS_CONF:     $conf"
  echo "REDIS_MAXMEM:   $maxmem"
  echo "REDIS_PASSWORD: $passwd"

  mkdir -p $data_dir
  chown redis:redis $data_dir

  curl -sSL "http://download.redis.io/redis-stable/redis.conf" -o $conf
  sed -i -e "s/^# requirepass foobared/requirepass $passwd/" $conf
  sed -i -e "s/^timeout 0/timeout 120/" $conf
  sed -i -e "s/^tcp-keepalive 0/tcp-keepalive 60/" $conf
  sed -i -e 's/^logfile ""/logfile "\/var\/log\/redis.log"/' $conf
  sed -i -e "s/^databases 16/databases 3/" $conf
  sed -i -e "s/^dir .\//dir \/data\/redis/" $conf
  sed -i -e "s/^# maxmemory <bytes>/maxmemory $maxmem/" $conf
}

svscanboot() {
  data_dir=$1
  if [ -z "$data_dir" ]; then
    echo "The Redis data dir must be passed as argument for $0 continue with the setup."
    exit 1
  fi

  conf=$1/redis.conf
  if [ ! -f "$conf" ]; then
    echo "Could not find redis configuration at $conf . $0 cannot continue with the setup."
    exit 1
  fi

  mkdir -p /etc/service/redis
  echo -e '#!/bin/bash\nredis-server' $conf >/etc/service/redis/run 
  chmod +x /etc/service/redis/run
  echo -e '\n# Svscanboot will load on startup and launch everyone under /etc/service' >> /etc/inittab
  echo -e 'SV:123456:respawn:/usr/bin/svscanboot' >> /etc/inittab
}


case "$1" in
  usrgrp)
    usrgrp
    ;;
  packages)
    packages
    ;;
  install)
    install
    ;;
  setup)
    setup $2 $3 $4
    ;;
  svscanboot)
    svscanboot $2
    ;;
  all)
    STEPS_NUM=5
    echo "Step 1 / $STEPS_NUM"
    usrgrp
    echo "Step 2 / $STEPS_NUM"
    packages
    echo "Step 3 / $STEPS_NUM"
    install
    echo "Step 4 / $STEPS_NUM"
    setup $2 $3
    echo "Step 5 / $STEPS_NUM"
    svscanboot $2
    echo "Finished all steps!"
    ;;
  *)
    echo "Usage: $0 {usrgrp|packages|install|setup|svscanboot|all}"
    echo ""
    echo "Details"
    echo "  usrgrp:          creates redis user and group"
    echo "  packages:        installs all basic packages such as vim, screen and so on"
    echo "  install:         installs Redis 2.8.19"
    echo "  setup DIR MEM:   configures Redis. DIR: redis data dir, recommended '/data/redis'. MEM: in bytes, 50Mb = '52428800'"
    echo "  svscanboot DIR:  setup process monitoring over Redis and auto startup on boot. DIR: the same used with setup step"
    echo "  all:             triggers all installing Redis from the scratch: usrgrp > packages > install > setup > svscanboot"
    echo ""
    exit 1
esac

exit 0
