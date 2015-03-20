#!/bin/bash

set -e

groupadd -r redis && useradd -r -g redis redis

exit 0
