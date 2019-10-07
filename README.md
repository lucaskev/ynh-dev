# ynh-dev - Yunohost dev environment manager

Repo for bootstrapping a gitlab-ci w/ a specific runner using custom executor LXD for installing and testing YNH w/ Bash, and Ansible (and maybe molecule). 

# TODO : make box privileged
# TODO : start w/ Debian 9

## Steps to build executor on VPS
1. SSH into it
2. Get root (`sudo su`)
3. Install LXD:
   1. `snap install lxd`
   2. `lxd init`
      1. `no`
      2. `yes`
      3. `default`
      4. (default)
      5. if btrfs like me: yes
      6. no
      7. "15GB"
      8. no
      9. yes
      10. lxdbr0
      11. auto
      12. auto
      13. no
      14. yes
      15. yes
  1.  Check if it is similar to:
```yaml
   config: {}
networks:
- config:
    ipv4.address: auto
    ipv6.address: auto
  description: ""
  managed: false
  name: lxdbr0
  type: ""
storage_pools:
- config:
    size: 15GB
  description: ""
  name: default
  driver: btrfs
profiles:
- config: {}
  description: ""
  devices:
    eth0:
      name: eth0
      nictype: bridged
      parent: lxdbr0
      type: nic
    root:
      path: /
      pool: default
      type: disk
  name: default
cluster: null
```
1. Clone this repo: `git clone https://gitlab.com/lucaskev/ynh-dev/`
2. `cd ynh-dev`
3.  `cp -r lxd-executor/ /opt`
4.  `cp config.toml.sample config.toml`
5.  Edit the config by adding the token obtained at [https://gitlab.com/lucaskev/ynh-dev/-/settings/ci_cd] (the "Set up a specific Runner manually" part): `vim config.toml`
6. Install gitlab-runner's repo: `curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh | bash` (think about sudo if you're not root)
7.  Install gitlab-runner: `apt-get install gitlab-runner`
<!-- 10. `gitlab-runner register` 
    1.  `https://gitlab.com/`
    2.  The token
    3.  A description
    4.  Tags
    5.  `custom`
    6.    -->
11. Copy the conf `cp config.toml /etc/gitlab-runner/`
12. Run Runner: `gitlab-runner run`
13. Report bugs and/or open file at `/etc/gitlab-runner/config.toml` and tweak accordingly

To test:
```bash
EXECUTOR_PATH=/opt/lxd-executor
gitlab-runner exec custom deploy_app --custom-run-exec $EXECUTOR_PATH/run.sh   --builds-dir "/builds"  --cache-dir "/cache" --custom-prepare-exec $EXECUTOR_PATH/prepare.sh --custom-cleanup-exec $EXECUTOR_PATH/cleanup.sh
```

## On macOS
On macOS I used multipass with a remote LXD (default IP should be at: 192.168.64.2)

# Remember that if you edit lxd-executor/* files you gotta copy them to /opt/lxd-executor on the host!