# ynh-dev - Yunohost dev environment manager

Repo for bootstrapping a gitlab-ci w/ a specific runner using custom executor LXD for installing and testing YNH w/ Bash, and Ansible (and maybe molecule). 

To test locally:
Adapt and copy config.toml.sample to ~/.gitlab-runner/config.toml if you're not root.

```bash
EXECUTOR_PATH=/home/USER/ynh-dev/lxd-executor
gitlab-runner exec custom deploy_app --custom-run-exec $EXECUTOR_PATH/run.sh   --builds-dir "/builds"  --cache-dir "/cache" --custom-prepare-exec $EXECUTOR_PATH/prepare.sh --custom-cleanup-exec $EXECUTOR_PATH/cleanup.sh
```