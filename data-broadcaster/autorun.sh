#!/usr/bin/env bash
while :
do
	ruby -I lib lib/wsst.rb prod
	echo "Server restart in 5 seconds, press [CTRL+C] to not restart it"
	sleep 5
done