#!/usr/bin/env bash

# /opt/lxd-executor/run.sh

currentDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source ${currentDir}/base.sh # Get variables from base.
# !!!!! Is that it???
CONTAINER_ID="runner-$CUSTOM_ENV_CI_RUNNER_ID-project-$CUSTOM_ENV_CI_PROJECT_ID-concurrent-$CUSTOM_ENV_CI_CONCURRENT_PROJECT_ID"


lxc exec "$CONTAINER_ID" /bin/bash < "${1}"
if [ $? -ne 0 ]; then
    # Exit using the variable, to make the build as failure in GitLab
    # CI.
    exit $BUILD_FAILURE_EXIT_CODE
fi