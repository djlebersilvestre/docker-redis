#!/bin/bash

set -e

scripts=${0%/*}/provision-steps
rm -rf $scripts
mkdir $scripts

github="https://raw.githubusercontent.com/djlebersilvestre/docker-redis-debian74/master/provision-steps"
curl -sSL "$github/usrgrp.sh"     -o $scripts/usrgrp.sh
curl -sSL "$github/packages.sh"   -o $scripts/packages.sh
curl -sSL "$github/install.sh"    -o $scripts/install.sh
curl -sSL "$github/setup.sh"      -o $scripts/setup.sh
curl -sSL "$github/svscanboot.sh" -o $scripts/svscanboot.sh
chmod +x -R $scripts

#   Step 1 - usrgrp:
#     creates redis user and group
#
#   Step 2 - packages:
#     installs all basic packages such as vim, screen and so on
#
#   Step 3 - install:
#     installs Redis 2.8.19
#
#   Step 4 - setup DIR MEM [PASS]:
#     configures Redis (data dir, password and so on)
#       DIR: redis data dir, recommended '/data/redis'
#       MEM: max redis memory in bytes, 50Mb = '52428800'
#       PASS: <optional> password for redis. If not given it will generate one
#
#   Step 5 - svscanboot DIR:
#     setup process monitoring over Redis and auto startup on boot
#       DIR: the same used with setup step

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
exit 0
