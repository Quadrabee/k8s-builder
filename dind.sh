#!/usr/bin/env sh
set -e

dockerd-entrypoint.sh &
CHILD_PID=$!
(while true; do if [[ -f "/builder/project/build.terminated" ]]; then kill $CHILD_PID; echo "Killed $CHILD_PID as the main container terminated."; fi; sleep 1; done) &
wait $CHILD_PID
if [[ -f "/builder/project/build.failed" ]]; then exit 1; echo "Job failed. Exiting..."; fi
if [[ -f "/builder/project/build.terminated" ]]; then exit 0; echo "Job completed. Exiting..."; fi
