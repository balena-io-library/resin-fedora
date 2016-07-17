#!/bin/bash

set -o errexit
set -o pipefail

export SUITES='23 24'
export ARCHS='armv7hf'
#TODO: add i386 and amd64
LATEST='22'
dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
date=$(date +'%Y%m%d' -u)

bash "$dir/build-image.sh"

for arch in $ARCHS; do
	for suite in $SUITES; do
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
			docker rmi -f $repo:$suite
			docker rmi -f $repo:$suite-$date
		done
	fi
done




