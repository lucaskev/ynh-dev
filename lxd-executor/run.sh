#!/usr/bin/env bash

echo "DEBUG:/opt/lxd-executor/run.sh"

currentDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source ${currentDir}/base.sh # Get variables from base.

CONTAINER_ID="runner-$CUSTOM_ENV_CI_RUNNER_ID-project-$CUSTOM_ENV_CI_PROJECT_ID-concurrent-$CUSTOM_ENV_CI_CONCURRENT_PROJECT_ID"

echo "DEBUG: Piping commands to lxc..."
# lxc exec "$CONTAINER_ID" "/sbin/ping 8.8.8.8 -c 4"
# lxc exec "$CONTAINER_ID" -- sh -c "echo 'DEBUG: Run command ls'"
# lxc exec "$CONTAINER_ID" -- sh -c "ls /builds/"
# lxc exec "$CONTAINER_ID" -- sh -c "echo 'DEBUG: Run command ansible'"
lxc file push "$CONTAINER_ID" ../test.yml /test.yml
ANSIBLE_CMD="ansible-playbook --connection=local /test.yml"
lxc exec "$CONTAINER_ID" -- sh -c "$ANSIBLE_CMD"

# lxc file push "$CONTAINER_ID" "${1}" "/tmp/script"
# lxc exec "$CONTAINER_ID" /bin/bash /tmp/script "${2}"

# lxc exec "$CONTAINER_ID" /bin/bash "${1}" "${2}"
lxc exec "$CONTAINER_ID" /bin/bash < "${1}"



if [ $? -ne 0 ]; then
    # Exit using the variable, to make the build as failure in GitLab
    # CI.
    exit $BUILD_FAILURE_EXIT_CODE
fi