
include_recipe 'conntrack'
include_recipe 'minikube'

# etcd_installation 'default' do
#   action :delete
# end

# etcd_service 'etcd0' do
#   advertise_client_urls 'http://127.0.0.1:4379'
#   listen_client_urls 'http://127.0.0.1:4379'
#   initial_advertise_peer_urls 'http://127.0.0.1:4380'
#   listen_peer_urls 'http://127.0.0.1:4380'
#   initial_cluster_token 'etcd-cluster-1'
#   initial_cluster 'etcd0=http://127.0.0.1:4380'
#   initial_cluster_state 'new'
#   action :stop
#   ignore_failure true # required for the first cluster build
# end

# etcd_key '/test' do
#   value 'test_value'
#   action :nothing
# end

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
  interpreter "bash"
  code <<-EOH
    su sloeinfra -c "minikube config set driver docker"
    su sloeinfra -c "minikube start --addons "dashboard  ingress ingress-dns" \
      --alsologtostderr=false --apiserver-ips 127.0.0.1 \
      --apiserver-name localhost --driver=docker --embed-certs=true --memory=2000m \
      --wait-timeout=6m0s"
    EOH
  only_if "su sloeinfra -c 'minikube status' | grep -q 'There is no local cluster'"
end

script "minikube_restart" do
  interpreter "bash"
  code <<-EOH
    su sloeinfra -c "minikube stop"
    su sloeinfra -c "minikube start --wait-timeout=2m0s"
  EOH
  not_if "su sloeinfra -c 'minikube status' | grep -q 'apiserver: Running'"
end
