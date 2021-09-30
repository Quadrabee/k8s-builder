#!/usr/bin/env sh
set -e

mkdir -p /etc/docker/

## Unfortunately jenkins doesn't support 'subPath' secret mounting
## Our hack is to look for /etc/docker.d/* files, and we copy them
## into /etc/docker/ before starting
if [ -d /etc/docker.d/ ]; then
  echo "Copying docker.d/ config files..."
  cp /etc/docker.d/* /etc/docker/
fi

## Disable encryption
export DOCKER_TLS_CERTDIR=""

dockerd-entrypoint.sh --mtu 1200 &
CHILD_PID=$!
(while true; do if [[ -f "/builder/project/build.terminated" ]]; then kill $CHILD_PID; echo "Killed $CHILD_PID as the main container terminated."; fi; sleep 1; done) &
wait $CHILD_PID
if [[ -f "/builder/project/build.failed" ]]; then exit 1; echo "Job failed. Exiting..."; fi
if [[ -f "/builder/project/build.terminated" ]]; then exit 0; echo "Job completed. Exiting..."; fi
