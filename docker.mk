.PHONY: help info build-all build login clean

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

DIR_WORK := /local/aws-elasticache-cluster-client-build
ARCHITECTURE := $(shell uname -m)

help:
	@cat $(firstword $(MAKEFILE_LIST))

info:
	docker buildx ls

build-all: \
	dist/memcached.x86_64.so \
	dist/memcached.aarch64.so

build: \
	dist/memcached.$(ARCHITECTURE).so

login: | dist/$(ARCHITECTURE).docker
	docker run -it --rm -v $(realpath .):$(DIR_WORK) -w $(DIR_WORK) $$(cat $|) bash

dist/memcached.x86_64.so: dist/x86_64.docker | dist
	docker run -v $(realpath .):$(DIR_WORK) -w $(DIR_WORK) $$(cat $<) make build
	mv dist/memcached.so $@

dist/memcached.aarch64.so: dist/aarch64.docker | dist
	docker run -v $(realpath .):$(DIR_WORK) -w $(DIR_WORK) $$(cat $<) make build
	mv dist/memcached.so $@

dist/x86_64.docker: Dockerfile | dist
	docker build -f $< --iidfile=$@ --platform=linux/amd64 $(foreach a,$(BUILD_ARGS),--build-arg $a) .

dist/aarch64.docker: Dockerfile | dist
	docker build -f $< --iidfile=$@ --platform=linux/arm64 $(foreach a,$(BUILD_ARGS),--build-arg $a) .

dist:
	-mkdir $@

clean:
	rm -rf dist
