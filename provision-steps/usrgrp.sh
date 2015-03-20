#!/bin/bash

if id -g "redis" > /dev/null 2>&1; then
  echo "Group redis already exists"
else
  groupadd -r redis
fi

if id -u "redis" > /dev/null 2>&1; then
  echo "User redis already exists"
else
  useradd -r -g redis redis
fi
