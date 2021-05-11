.PHONY: help setup build check clean

help:
	@cat $(firstword $(MAKEFILE_LIST))

setup: \
	aws-elasticache-cluster-client-libmemcached \
	aws-elasticache-cluster-client-memcached-for-php

build: \
		/usr/local/lib/pkgconfig/libmemcached.pc \
		/usr/lib64/php/modules/memcached.so \
		check \
		dist/memcached.so

aws-elasticache-cluster-client-libmemcached:
	git submodule update --init $@

aws-elasticache-cluster-client-memcached-for-php:
	git submodule update --init $@

/usr/local/lib/pkgconfig/libmemcached.pc:
	cd /build/aws-elasticache-cluster-client-libmemcached \
    && for F in /build/*.patch; do patch -p1 -i "$$F"; done \
    && autoreconf -i \
    && mkdir BUILD \
    && cd BUILD \
    && ../configure --prefix=/usr/local --with-pic --disable-sasl \
    && make -j`nproc` \
    && make install

/usr/lib64/php/modules/memcached.so:
	cd /build/aws-elasticache-cluster-client-memcached-for-php \
			&& phpize \
			&& ./configure \
			--with-pic \
			--disable-memcached-sasl \
			--enable-memcached-session \
			`if [ $ENABLE_JSON -eq 1 ]; then echo "--enable-memcached-json"; fi` \
			`if [ $ENABLE_MSGPACK -eq 1 ]; then echo "--enable-memcached-msgpack"; fi` \
			`if [ $ENABLE_IGBINARY -eq 1 ]; then echo "--enable-memcached-igbinary"; fi` \
			&& sed -i "s#-lmemcached#/usr/local/lib/libmemcached.a -lcrypt -lpthread -lm -lstdc++ -lsasl2#" Makefile \
			&& sed -i "s#-lmemcachedutil#/usr/local/lib/libmemcachedutil.a#" Makefile \
			&& make -j`nproc` \
			&& make install

dist/memcached.so: | dist
	cp -p /usr/lib64/php/modules/memcached.so $@

/build/final:
	-mkdir $@

check:
	php -v
	php -dextension=memcached.so -m | grep 'memcached'
	php -dextension=memcached.so -r 'new Memcached();'
	php -dextension=memcached.so -r 'if (!defined("Memcached::DYNAMIC_CLIENT_MODE")) exit(1);'
	php-fpm -v
	php-fpm -dextension=memcached.so -m | grep 'memcached'

clean:
	rm -rf aws-elasticache-cluster-client-libmemcached
	rm -rf aws-elasticache-cluster-client-memcached-for-php
	rm -rf /build/aws-elasticache-cluster-client-libmemcached/configure
	rm -rf /build/aws-elasticache-cluster-client-libmemcached/BUILD
