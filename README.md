# docker-redis-debian74
==================

Dockerfile to build an image of Redis 2.8.19 over a Debian 7.4. The goal is to
build an image that is similar to the one provided by Cloud At Cost, allowing
us to test and develop with basically the same architecture of the production
environment. The base script was extracted from:
https://github.com/docker-library/redis/tree/master/2.8

Getting started
---------------

I recommend that you configure your current user to manipulate docker without sudo.
Check [this](http://askubuntu.com/questions/477551/how-can-i-use-docker-without-sudo) out to learn how.

1. Build the new image (from the same directory of this Dockerfile):
```
$ docker build -t djlebersilvestre/redis:2.8.19 .
$ docker images
REPOSITORY                  TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
djlebersilvestre/redis      2.8.19              4f7c1d4185ec        2  seconds ago      258.5 MB

```
Or you can build directly from git:
```
$ docker build -t djlebersilvestre/redis:2.8.19 https://github.com/djlebersilvestre/docker-redis-debian74.git
```

2. Start the server:
```
$ docker run --name redis -d -p 127.0.0.1:6379:6379 djlebersilvestre/redis:2.8.19
```

3. Access the server with the client already installed in the image:
```
$ docker run --rm -it --link redis:redis djlebersilvestre/redis:2.8.19 sh -c 'exec redis-cli -h "$REDIS_PORT_6379_TCP_ADDR" -p "$REDIS_PORT_6379_TCP_PORT"'
```
Or you can setup your application / client to `host=127.0.0.1`,  `port=6379` and `password=...<see below>`
Getting the password:
```
$ docker run --rm -it djlebersilvestre/redis:2.8.19 sh -c 'exec echo $(grep "^requirepass \w\+" $REDIS_CONF)'
```

### To run the image and poke around its file system
```
$ docker run --rm -it djlebersilvestre/redis:2.8.19 /bin/bash
```

### To build a new Dockerfile upon this image (use the public image \o/)
```
FROM djlebersilvestre/redis:2.8.19
# customize your image
```
