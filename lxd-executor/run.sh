#!/usr/bin/env bash

echo "DEBUG:/opt/lxd-executor/run.sh"

currentDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source ${currentDir}/base.sh # Get variables from base.

CONTAINER_ID="runner-$CUSTOM_ENV_CI_RUNNER_ID-project-$CUSTOM_ENV_CI_PROJECT_ID-concurrent-$CUSTOM_ENV_CI_CONCURRENT_PROJECT_ID"

echo "DEBUG:Try to pipe to lxc..."
# lxc exec "$CONTAINER_ID" "/sbin/ping 8.8.8.8 -c 4"
lxc exec "$CONTAINER_ID" -- sh -c "echo 'DEBUG: Run command ls'"
lxc exec "$CONTAINER_ID" -- sh -c "ls"
lxc exec "$CONTAINER_ID" -- sh -c "echo 'DEBUG: Run command ansible'"
ANSIBLE_CMD="ansible-playbook --connection=local 127.0.0.1 test.yml"
lxc exec "$CONTAINER_ID" -- sh -c "$ANSIBLE_CMD"
# lxc exec "$CONTAINER_ID" < ../prebuild.sh

# lxc exec "$CONTAINER_ID" /bin/bash < "$(build_script)"
# lxc exec "$CONTAINER_ID" /bin/bash < "${1}"



if [ $? -ne 0 ]; then
    # Exit using the variable, to make the build as failure in GitLab
    # CI.
    exit $BUILD_FAILURE_EXIT_CODE
fi