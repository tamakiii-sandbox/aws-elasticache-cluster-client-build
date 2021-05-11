# aws-elasticache-cluster-client-build

This repository is fork of [https://github.com/Planerio/aws-elasticache-cluster-client-build](https://github.com/Planerio/aws-elasticache-cluster-client-build).
- PHP 8.0 with `amazon-linux-extras enable php8.0`
- `x86_64` and `aarch64` Support

## How to use
```sh
make setup
make -f docker.mk build # or build-all
ls -lsa dist/*.so
```
```sh
make -f docker.mk
make clean
```

## Options
```sh
make -f docker.mk build \
  OS_VERSION=2.0.20210126.0 \
  PHP_VERSION=7.4 \
  ENABLE_IGBINARY=1 \
  ENABLE_MSGPACK=1 \
  ENABLE_JSON=1
```
