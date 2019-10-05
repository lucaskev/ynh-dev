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