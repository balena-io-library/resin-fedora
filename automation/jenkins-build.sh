#!/bin/bash

set -o errexit
set -o pipefail

export SUITES='23 24'
export ARCHS='armv7hf aarch64 amd64'
#TODO: add i386 and amd64
LATEST='24'
dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
date=$(date +'%Y%m%d' -u)

bash "$dir/build-image.sh"

for arch in $ARCHS; do
	for suite in $SUITES; do
		if [ $arch == 'aarch64' ] && [ $suite == '23' ]; then
			continue
		fi
		repo="resin/$arch-fedora"
		docker tag -f $repo:$suite $repo:$suite-$date
		if [ $LATEST == $suite ]; then
			docker tag -f $repo:$suite $repo:latest
		fi
	done

	docker push $repo

	# Clean up unnecessarry docker images after pushing
	if [ $? -eq 0 ]; then
		for suite in $SUITES; do
			docker rmi -f $repo:$suite || true
			docker rmi -f $repo:$suite-$date || true
		done
	fi
done




