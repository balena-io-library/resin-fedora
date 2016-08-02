#!/bin/bash

set -o errexit
set -o pipefail

QEMU_VERSION='2.5.0-resin-rc3'
QEMU_SHA256='dc36002fd3e362710e1654c4dfdc84a064b710e10a2323e8e4c8e24cb3921818'

# Download QEMU
curl -SLO https://github.com/resin-io/qemu/releases/download/$QEMU_VERSION/qemu-$QEMU_VERSION.tar.gz \
	&& echo "$QEMU_SHA256  qemu-$QEMU_VERSION.tar.gz" > qemu-$QEMU_VERSION.tar.gz.sha256sum \
	&& sha256sum -c qemu-$QEMU_VERSION.tar.gz.sha256sum \
	&& tar -xz --strip-components=1 -f qemu-$QEMU_VERSION.tar.gz

for arch in $ARCHS; do
	for suite in $SUITES; do

		case "$arch" in
		'armhf')
			label='io.resin.architecture="armhf" io.resin.qemu.version="'$QEMU_VERSION'"'
			qemu='COPY qemu-arm-static /usr/bin/'
			repo="resin/$arch-fedora"
		;;
		esac

		rootfs_file="Fedora-Docker-Base-$suite.$arch.tar.xz"
		checksum=$(grep " $rootfs_file" SHASUMS256.txt)
		curl -SLO "http://resin-packages.s3.amazonaws.com/fedora/$suite/$rootfs_file"
		echo "$checksum" | sha256sum -c -
		rm -rf tmp
		mkdir tmp
		tar -xJvf $rootfs_file -C tmp --strip-components=1
		docker import tmp/layer.tar $repo:$suite

		sed -e s~#{FROM}~"$repo:$suite"~g \
			-e s~#{LABEL}~"$label"~g \
			-e s~#{QEMU}~"$qemu"~g Dockerfile.tpl > Dockerfile

		docker build -t $repo:$suite .
		rm -rf "$rootfs_file"
	done
done

rm -rf qemu*
