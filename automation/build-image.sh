#!/bin/bash

set -o errexit
set -o pipefail

QEMU_VERSION='2.5.0-resin-rc3'
QEMU_SHA256='dc36002fd3e362710e1654c4dfdc84a064b710e10a2323e8e4c8e24cb3921818'
MIRROR='http://archive.raspbian.org/raspbian'

# Download QEMU
curl -SLO https://github.com/resin-io/qemu/releases/download/$QEMU_VERSION/qemu-$QEMU_VERSION.tar.gz \
	&& echo "$QEMU_SHA256  qemu-$QEMU_VERSION.tar.gz" > qemu-$QEMU_VERSION.tar.gz.sha256sum \
	&& sha256sum -c qemu-$QEMU_VERSION.tar.gz.sha256sum \
	&& tar -xz --strip-components=1 -f qemu-$QEMU_VERSION.tar.gz

for arch in $ARCHS; do
	for suite in $SUITES; do

		case "$arch" in
		'armhf')
			baseImage='scratch'
			label='io.resin.architecture="armhf" io.resin.qemu.version="'$QEMU_VERSION'"'
			qemu='COPY qemu-arm-static /usr/bin/'
			repo="resin/$arch-fedora"
		;;
		esac

		rootfs_file='fedora-minimal-$arch-$suite.tar.gz'
		checksum=$(grep " $rootfs_file" SHASUMS256.txt)
		curl -SLO "http://resin-packages.s3.amazonaws.com/fedora/$suite/$rootfs_file"
		echo "$checksum" | sha256sum -c -

		sed -e s~#{FROM}~"$baseImage"~g \
			-e s~#{LABEL}~"$label"~g \
			-e s~#{QEMU}~"$qemu"~g \
			-e s~#{ROOTFS}~"ADD $rootfs_file /"~g Dockerfile.tpl > Dockerfile

		docker build -t $repo:$suite .
		rm -rf "$rootfs_file"
	done
done

rm -rf qemu*
