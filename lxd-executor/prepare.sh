#!/usr/bin/env bash

# /opt/lxd-executor/prepare.sh

currentDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source ${currentDir}/base.sh # Get variables from base.

set -eo pipefail

# trap any error, and mark it as a system failure.
trap "exit $SYSTEM_FAILURE_EXIT_CODE" ERR

CONTAINER_ID="runner-$CUSTOM_ENV_CI_RUNNER_ID-project-$CUSTOM_ENV_CI_PROJECT_ID-concurrent-$CUSTOM_ENV_CI_CONCURRENT_PROJECT_ID"

start_container () {
    if lxc info "$CONTAINER_ID" >/dev/null 2>/dev/null ; then
        echo 'Found old container, deleting'
        lxc delete -f "$CONTAINER_ID"
    fi

    # Container image is harcoded at the moment, since Custom executor
    # does not provide the value of `image`. See
    # https://gitlab.com/gitlab-org/gitlab-runner/issues/4357 for
    # details.
    # lxc launch ubuntu:18.04 "$CONTAINER_ID"
    lxc launch images:debian/stretch/amd64 "$CONTAINER_ID"
    lxc config set "$CONTAINER_ID" security.privileged true


    # Wait for container to start, we are using systemd to check this,
    # for the sake of brevity.
    for i in $(seq 1 10); do
        if lxc exec "$CONTAINER_ID" -- sh -c "systemctl isolate multi-user.target" >/dev/null 2>/dev/null; then
            break
        fi

        if [ "$i" == "10" ]; then
            echo 'Waited for 10 seconds to start container, exiting..'
            # Inform GitLab Runner that this is a system failure, so it
            # should be retried.
            exit "$SYSTEM_FAILURE_EXIT_CODE"
        fi

        sleep 1s
    done
}

install_dependencies () {
    echo 'DEBUG: Ping'
    lxc exec "$CONTAINER_ID" -- sh -c "ping 8.8.8.8 -c"
    echo 'DEBUG: Updating'
    lxc exec "$CONTAINER_ID" -- sh -c "apt-get update"
    echo 'DEBUG: Installing sudo and curl'
    lxc exec "$CONTAINER_ID" -- sh -c "apt-get install --yes curl sudo"
    # Install Git LFS, git comes pre installed with ubuntu image.
    lxc exec "$CONTAINER_ID" -- sh -c "curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash"
    lxc exec "$CONTAINER_ID" -- sh -c "apt-get install git-lfs"

    # Install gitlab-runner binary since we need for cache/artifacts.
    lxc exec "$CONTAINER_ID" -- sh -c "curl -L --output /usr/local/bin/gitlab-runner https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-linux-amd64"
    lxc exec "$CONTAINER_ID" -- sh -c "chmod +x /usr/local/bin/gitlab-runner"
}

echo "Running in $CONTAINER_ID"

start_container

install_dependencies