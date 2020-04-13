# sloeinfra
Sloe infrastructure scripts

To bring up a workstation on Ubuntu 18.04 LTS:

    sudo apt update
    sudo apt install git
    mkdir r
    cd r
    git clone https://github.com/sloe/sloeinfra.git
    cd sloeinfra/bringup/
    ./ubuntu-workstation.sh

To install and configure Kubernetes on Docker.  This doesn't install a
 hypervisor (VirtualBox, KVM) but uses the --driver=docker option with
 Minikube, so can run on a VM itself.

    cd ~/r/sloeinfra/bringup
    # script[minukube_setup] in the command below is a slow step
    ./k8s-single-node.sh
    
    # The sloeinfra user will have been created by the above script,
    # and should be used to manage minikube, although its credentials
    # can be taken from the ~sloeinfra/.kube/config file.
    sudo su - sloeinfra
