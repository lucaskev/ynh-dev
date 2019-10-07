export DEBIAN_FRONTEND=noninteractive

set -e

# Configure guest hostname
sudo bash -c 'echo 127.0.1.1 ynh.local yunohost >> /etc/hosts'
sudo hostname ynh.local
sudo bash -c 'echo ynh.local > /etc/hostname'

# Define root password
echo -e "yunohost\nyunohost" | sudo passwd root

# Allow sudo removal (YunoHost use sudo-ldap)
export SUDO_FORCE_REMOVE=yes

# Upgrade guest (done in install script)
sudo apt-get update
sudo apt-get -y --force-yes upgrade
sudo apt-get -y --force-yes dist-upgrade

# Install YunoHost
wget https://raw.githubusercontent.com/YunoHost/install_script/stretch/install_yunohost -q -O /tmp/install_yunohost
# Shouldn't it be stable?
sudo bash /tmp/install_yunohost -a -d stable
# sudo bash /tmp/install_yunohost -a -d unstable

# Cleanup
sudo apt-get clean -y