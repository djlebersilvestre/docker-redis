#!/bin/bash

set -e

apt-get update && apt-get upgrade -y \
  && apt-get install -y vim curl pwgen procps screen daemontools

exit 0
