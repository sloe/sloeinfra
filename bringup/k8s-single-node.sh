#!/bin/bash
# Kubernetes single node

set -e
trap 'catch $? $LINENO' EXIT
catch() {
  if [ "$1" != "0" ]; then
    echo "Error $1 occurred on $2"
  fi
}

SUDO=sudo

mkdir -p ~/packages
cd ~/packages

if [ ! -x "$(command -v cfssl)" ] ;  then
  $SUDO apt-get install -y golang-cfssl
fi

if [ ! -x "$(command -v kubectl)" ] ;  then
  wget -O - https://packages.cloud.google.com/apt/doc/apt-key.gpg | $SUDO apt-key add -
  $SUDO touch /etc/apt/sources.list.d/kubernetes.list
  echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | $SUDO tee -a /etc/apt/sources.list.d/kubernetes.list
  $SUDO apt-get update
  $SUDO apt-get install -y kubeadm kubelet kubectl
fi

if [ ! -x "$(command -v chef)" ] ;  then
  # Find version from https://downloads.chef.io/chef-workstation/
  CHEF_WORKSTATION_MAJOR_VERSION=0.17.5
  CHEF_WORKSTATION_VERSION=${CHEF_WORKSTATION_MAJOR_VERSION}-1
  CHEF_WORKSTAION_FILENAME=chef-workstation_${CHEF_WORKSTATION_VERSION}_amd64.deb
  wget https://packages.chef.io/files/stable/chef-workstation/${CHEF_WORKSTATION_MAJOR_VERSION}/ubuntu/18.04/${CHEF_WORKSTAION_FILENAME}
  $SUDO dpkg -i chef-workstation_*.deb
fi

git config --global core.editor "vim"
git config --global user.name "Sloe"
git config --global user.email "4004821+sloe@users.noreply.github.com"

mkdir -p ~/r
cd ~/r

test -d sloeinfra || git clone https://github.com/sloe/sloeinfra.git
# chef generate cookbook --berks sloeinfra

cd sloeinfra

berks vendor cookbooks

sudo chef-client --local-mode --override-runlist sloeinfra::k8s_single_node

sudo gpasswd -a $USER docker

echo
echo "To work with modifiable sloeinfra repo, use"
echo "cat ~/.ssh/id_rsa.pub # and add key to github.com"
echo "cd ~/r/sloeinfra && git remote set-url origin git@github.com:sloe/sloeinfra.git"
echo
echo "To rerun this script use sloe_reinfra"
