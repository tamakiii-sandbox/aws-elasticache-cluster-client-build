FROM amazonlinux:${OS_VERSION:-2}

SHELL ["/bin/bash", "-c"]

# can be 7.1 or later:
ARG PHP_VERSION=8.0
# set to 1 to enable:
ARG ENABLE_IGBINARY=0
# set to 1 to enable:
ARG ENABLE_MSGPACK=0
# set to 1 to enable:
ARG ENABLE_JSON=0

RUN yum update -y && \
    yum install -y \
        patch \
        make \
        gcc \
        gcc-c++ \
        autoconf \
        automake \
        libtool \
        pkgconfig \
        zlib \
        zlib-devel \
        cyrus-sasl-devel

RUN amazon-linux-extras enable php$PHP_VERSION && \
	  yum clean metadata

RUN yum -y install php-devel php-fpm \
    && if [ $ENABLE_IGBINARY -eq 1 ]; then yum -y install php-igbinary-devel; fi \
    && if [ $ENABLE_MSGPACK -eq 1 ]; then yum -y install php-pecl-msgpack-devel; fi

RUN yum clean all && \
    rm -rf /var/cache/yum/*

RUN mkdir /build

COPY aws-elasticache-cluster-client-libmemcached /build/aws-elasticache-cluster-client-libmemcached
COPY aws-elasticache-cluster-client-memcached-for-php /build/aws-elasticache-cluster-client-memcached-for-php
COPY *.patch /build/
