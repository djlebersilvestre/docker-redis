#!/bin/bash

set -e

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

if grep -q "svscanboot" /etc/inittab; then
  echo "Svscanboot already configured to be loaded on startup. Skipping this step."
else
  echo -e '\n# Svscanboot will load on startup and launch everyone under /etc/service' >> /etc/inittab
  echo -e 'SV:123456:respawn:/usr/bin/svscanboot' >> /etc/inittab
fi
