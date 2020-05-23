#!/bin/bash
# Ubuntu Hyper-V workstation

set -e
trap 'catch $? $LINENO' EXIT
catch() {
  if [ "$1" != "0" ]; then
    echo "Error $1 occurred on $2"
  fi
}

UBUNTU_VERSION=`lsb_release -rs`

snap_bin_path="/snap/bin"
if [ -n "${PATH##*${snap_bin_path}}" -a -n "${PATH##*${snap_bin_path}:*}" ]; then
    echo "${snap_bin_path} not in path, is this a login shell (su -)?  Exiting."
    exit 1
fi

if [ ! -f ~/.ssh/id_rsa.pub ] ; then
  cat /dev/zero | ssh-keygen -q -N ""
fi

SUDO=sudo
if [ ! -x "$(command -v gitk)" ] ;  then
  $SUDO apt-get install -y git gitk gnome-tweak-tool vim
fi

if [ ! -x "$(command -v code)" ] ;  then
  $SUDO snap install --classic code
  code --install-extension chef-software.chef
  code --install-extension eamodio.gitlens
  code --install-extension coolbear.systemd-unit-file
fi

mkdir -p ~/packages
cd ~/packages

if [ ! -x "$(command -v chef)" ] ;  then
  # Find version from https://downloads.chef.io/chef-workstation/
  CHEF_WORKSTATION_MAJOR_VERSION=0.17.5
  CHEF_WORKSTATION_VERSION=${CHEF_WORKSTATION_MAJOR_VERSION}-1
  CHEF_WORKSTAION_FILENAME=chef-workstation_${CHEF_WORKSTATION_VERSION}_amd64.deb
  wget https://packages.chef.io/files/stable/chef-workstation/${CHEF_WORKSTATION_MAJOR_VERSION}/ubuntu/18.04/${CHEF_WORKSTAION_FILENAME}
  $SUDO dpkg -i chef-workstation_*.deb
fi

git config --global core.editor "vim"
if [ "$USER" == "andy" ] ; then
  git config --global user.name "Sloe"
  git config --global user.email "4004821+sloe@users.noreply.github.com"
fi

if [ "$USER" == "mushware" ] ; then
  git config --global user.name "Andy Southgate"
  git config --global user.email "andy@mushware.com"
fi

mkdir -p ~/r
cd ~/r

test -d sloeinfra || git clone https://github.com/sloe/sloeinfra.git
# chef generate cookbook --berks sloeinfra

cd sloeinfra


if [ ! -f ~/.bash_aliases_local ] ; then
  touch ~/.bash_aliases_local
  if [ -f ~/.bash_aliases ] ; then
    cat ~/.bash_aliases > ~/.bash_aliases_local
  fi
fi

cp -fpR ~/.bash_aliases_local ~/.bash_aliases
cat bringup/templates/linux-bash-aliases.sh >> ~/.bash_aliases
cat bringup/templates/ubuntu-workstation-bash-aliases.sh >> ~/.bash_aliases

berks vendor cookbooks

sudo chef-client --local-mode --override-runlist sloeinfra::linux_workstation

source ~/.bash_aliases

echo
echo "To work with modifiable sloeinfra repo, use"
echo "cat ~/.ssh/id_rsa.pub # and add key to github.com"
echo "cd ~/r/sloeinfra && git remote set-url origin git@github.com:sloe/sloeinfra.git"
echo
echo "To rerun this script use sloe_reinfra"
