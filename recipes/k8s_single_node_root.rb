
include_recipe 'conntrack'
include_recipe 'minikube'

script "packet_forwarding" do
  interpreter "bash"
  code <<-EOH
    echo "# Added sloeinfra::k8s_single_node Chef recipe" >> /etc/sysctl.conf
    echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
  EOH
  not_if "grep '^net\.ipv4\.ip_forward=1' /etc/sysctl.conf"
end

docker_service 'default' do
  dns ['1.1.1.1', '1.0.0.1']
  dns_search []
  ipv6 false
  logfile '/var/log/docker.log'
  misc_opts '--exec-opt native.cgroupdriver=systemd'
  action [:create, :start]
end

docker_image 'busybox' do
  action :pull
end

group 'sloeinfra' do
  gid 10020
end

user 'sloeinfra' do
  gid 'sloeinfra'
  home '/home/sloeinfra'
  manage_home true
  shell '/bin/bash'
  uid 10020
end

group 'docker' do
  members ['sloeinfra']
  action :modify
end

script "minikube_setup" do
  code <<-EOH
    minikube status
    minikube config set driver none
    minikube start --addons "dashboard ingress ingress-dns" \
      --alsologtostderr=false --apiserver-ips 127.0.0.1 \
      --apiserver-name localhost --embed-certs=true \
      --wait-timeout=6m0s
  EOH
  environment 'HOME' => '/root'
  guard_interpreter :bash
  interpreter "bash"
  only_if "minikube status | grep -q 'There is no local cluster'"
end

script "minikube_restart" do
  code <<-EOH
    minikube stop
    minikube start --embed-certs=true --wait-timeout=2m0s
  EOH
  environment 'HOME' => '/root'
  guard_interpreter :bash
  interpreter "bash"
  not_if "minikube status | grep -q 'apiserver: Running'"
end
