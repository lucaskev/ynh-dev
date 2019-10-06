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
    lxc launch ubuntu:18.04 "$CONTAINER_ID"

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
    # Install Git LFS, git comes pre installed with ubuntu image.
    # lxc exec "$CONTAINER_ID" -- sh -c "curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash"
    # lxc exec "$CONTAINER_ID" -- sh -c "apt-get install git-lfs"
    echo "DEBUG: Trying to curl"
    # Install gitlab-runner binary since we need for cache/artifacts.
    lxc exec "$CONTAINER_ID" -- sh -c "curl -L --output /usr/local/bin/gitlab-runner https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-linux-amd64"
    echo "DEBUG: Trying to chmod"
    lxc exec "$CONTAINER_ID" -- sh -c "chmod +x /usr/local/bin/gitlab-runner"
    
    lxc exec "$CONTAINER_ID" -- sh -c "apt-add-repository --yes --update ppa:ansible/ansible"
    lxc exec "$CONTAINER_ID" -- sh -c "apt-get install ansible"
}

echo "Running in $CONTAINER_ID"

start_container

install_dependencies


# # prebuild.sh:
# export DEBIAN_FRONTEND=noninteractive

# # Configure guest hostname
# sudo bash -c 'echo 127.0.1.1 yunohost.yunohost.org yunohost >> /etc/hosts'
# sudo hostname yunohost.yunohost.org
# sudo bash -c 'echo yunohost.yunohost.org > /etc/hostname'

# # Define root password
# echo -e "yunohost\nyunohost" | sudo passwd root

# # Allow sudo removal (YunoHost use sudo-ldap)
# export SUDO_FORCE_REMOVE=yes

# # Upgrade guest (done in install script)
# sudo apt-get update
# sudo apt-get -y --force-yes upgrade
# sudo apt-get -y --force-yes dist-upgrade

# # Install YunoHost
# wget https://raw.githubusercontent.com/YunoHost/install_script/stretch/install_yunohost -q -O /tmp/install_yunohost
# sudo bash /tmp/install_yunohost -a -d unstable

# # Cleanup
# sudo apt-get clean -y