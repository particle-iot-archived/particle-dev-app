#!/bin/bash

if [[ -z $TARGET_OS ]]; then
	echo "⛔️ Please define OS variable (darwin/win)"
	exit 1
fi

if [[ -z $TARGET_ARCH ]]; then
	if [[ $TARGET_OS == "win" ]]; then
		echo "⚠️ TARGET_ARCH not defined. Assuming 32-bit"
	fi
fi

fly -t main execute \
	--config ci/$TARGET_OS.yml \
	--exclude-ignored \
	-i sources=. \
	-o artefacts=${HOME}/Desktop/Dev/${TARGET_OS}${TARGET_ARCH}
