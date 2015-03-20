#!/bin/bash

set -e

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

exit 0
