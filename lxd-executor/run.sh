#!/usr/bin/env bash

echo "DEBUG:/opt/lxd-executor/run.sh"

currentDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source ${currentDir}/base.sh # Get variables from base.


lxc exec "$CONTAINER_ID" "/sbin/ping 8.8.8.8 -c 4"
# lxc exec "$CONTAINER_ID" < ../prebuild.sh
lxc exec "$CONTAINER_ID" /bin/bash < "${1}"



if [ $? -ne 0 ]; then
    # Exit using the variable, to make the build as failure in GitLab
    # CI.
    exit $BUILD_FAILURE_EXIT_CODE
fi