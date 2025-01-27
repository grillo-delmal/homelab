#!/usr/bin/env bash


if [ -z "$1" ]; then
	echo "Please provide your steam login name as the first argument."
	exit
fi

/steamcmd/steamcmd.sh \
	+force_install_dir /check/ \
	+login "$1" \
	+app_update 211820 validate \
	+quit
exit
