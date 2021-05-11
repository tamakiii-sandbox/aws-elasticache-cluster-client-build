.PHONY: help setup info build clean

export OS_VERSION ?= 2

export PHP_VERSION ?= 8.0
export ENABLE_IGBINARY ?= 0
export ENABLE_MSGPACK ?= 0
export ENABLE_JSON ?= 0

BUILD_ARGS := \
	PHP_VERSION=$(PHP_VERSION) \
	ENABLE_IGBINARY=$(ENABLE_IGBINARY) \
	ENABLE_MSGPACK=$(ENABLE_MSGPACK) \
	ENABLE_JSON=$(ENABLE_JSON)

help:
	@cat $(firstword $(MAKEFILE_LIST))

setup: \
	aws-elasticache-cluster-client-libmemcached \
	aws-elasticache-cluster-client-memcached-for-php

info:
	docker buildx ls

build: \
	dist/memcached.amazonlinux2.x86_64.so \
	dist/memcached.amazonlinux2.aarch64.so

aws-elasticache-cluster-client-libmemcached:
	git submodule update --init $@

aws-elasticache-cluster-client-memcached-for-php:
	git submodule update --init $@

dist/memcached.amazonlinux2.x86_64.so: dist/amazonlinux2.linux-amd64.docker | dist
	docker cp $$(docker create $$(cat $<)):/build/final/memcached.so $@

dist/memcached.amazonlinux2.aarch64.so: dist/amazonlinux2.linux-arm64.docker | dist
	docker cp $$(docker create $$(cat $<)):/build/final/memcached.so $@

dist/amazonlinux2.linux-amd64.docker: Dockerfile.amazonlinux2 | dist
	docker build -f $< --iidfile=$@ --platform=linux/amd64 $(foreach a,$(BUILD_ARGS),--build-arg $a) .

dist/amazonlinux2.linux-arm64.docker: Dockerfile.amazonlinux2 | dist
	docker build -f $< --iidfile=$@ --platform=linux/arm64 $(foreach a,$(BUILD_ARGS),--build-arg $a) .

dist:
	-mkdir $@

clean:
	rm -rf dist
