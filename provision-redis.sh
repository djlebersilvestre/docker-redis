#!/bin/bash

set -e
scripts=${0%/*}/provision-steps

case "$1" in
  all)
    STEPS_NUM=5
    echo "Step 1 / $STEPS_NUM"
    . $scripts/usrgrp.sh
    echo "Step 2 / $STEPS_NUM"
    . $scripts/packages.sh
    echo "Step 3 / $STEPS_NUM"
    . $scripts/install.sh
    echo "Step 4 / $STEPS_NUM"
    . $scripts/setup.sh $2 $3 $4
    echo "Step 5 / $STEPS_NUM"
    . $scripts/svscanboot.sh $2
    echo "Finished all steps!"
    ;;
  *)
    echo "Usage: $0 {all}"
    echo ""
    echo "Details"
    echo "  all DIR MEM PASS:"
    echo "    triggers all installing Redis from the scratch: usrgrp > packages > install > setup > svscanboot"
    echo ""
    echo ""
    echo "  Step 1 - usrgrp:"
    echo "    creates redis user and group"
    echo ""
    echo "  Step 2 - packages:"
    echo "    installs all basic packages such as vim, screen and so on"
    echo ""
    echo "  Step 3 - install:"
    echo "    installs Redis 2.8.19"
    echo ""
    echo "  Step 4 - setup DIR MEM [PASS]:"
    echo "    configures Redis (data dir, password and so on)"
    echo "      DIR: redis data dir, recommended '/data/redis'"
    echo "      MEM: max redis memory in bytes, 50Mb = '52428800'"
    echo "      PASS: <optional> password for redis. If not given it will generate one"
    echo ""
    echo "  Step 5 - svscanboot DIR:"
    echo "    setup process monitoring over Redis and auto startup on boot"
    echo "      DIR: the same used with setup step"
    echo ""
    exit 1
esac

exit 0
