# sloeinfra
Sloe infrastructure scripts

To bring up a workstation on Ubuntu 18.04 LTS:

    sudo apt update
    sudo apt install -y git
    mkdir r
    cd r
    git clone https://github.com/sloe/sloeinfra.git
    cd sloeinfra/bringup/
    ./ubuntu-workstation.sh
    # Enter an empty Chef server URL if asked

To install and configure Kubernetes nested within Docker.  This doesn't
install a hypervisor (VirtualBox, KVM) but uses the --driver=docker option
with Minikube, so can run on a VM itself.

    cd ~/r/sloeinfra/bringup
    # script[minukube_setup] in the commands below is a slow step
    ./k8s-single-node.sh docker
    # To install on the base OS instead, use ./k8s-single-node.sh root
    
    # The sloeinfra user will have been created by the above script,
    # and should be used to manage minikube, although its credentials
    # can be taken from the ~sloeinfra/.kube/config file.
    sudo su - sloeinfra



## OVH bringup for Ubuntu 18.04
First of all, enable the firewall:

    ufw allow ssh
    ufw enable
    ufw status verbose

Add the following as /etc/netplan/51-cloud-init-ipv6.yaml, substituting IPv6 details
from the control panel:

    network:
      version: 2
      ethernets:
        ens3:
          dhcp6: false
          match:
            name: ens3
          addresses:
            - "IPV6_ADDR/128"
          gateway6: "IPV6_GATEWAY"
          routes:
            - to: "IPV6_GATEWAY"
              scope: link

Then:

    netplan apply
    ping google.com # Should ping IPv6 address successfully
    # Uncomment line `precedence ::ffff:0:0/96  100` in /etc/gai.conf to
    # prefer IPv4

Then you can procedure to clone the sloeinfra repo and run `k8s-single-node.sh`.
