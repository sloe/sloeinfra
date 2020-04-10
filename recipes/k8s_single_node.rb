

etcd_installation 'default' do
  action :create
end

etcd_service 'etcd0' do
  advertise_client_urls 'http://127.0.0.1:2379'
  listen_client_urls 'http://127.0.0.1:2379'
  initial_advertise_peer_urls 'http://127.0.0.1:2380'
  listen_peer_urls 'http://127.0.0.1:2380'
  initial_cluster_token 'etcd-cluster-1'
  initial_cluster 'etcd0=http://127.0.0.1:2380'
  initial_cluster_state 'new'
  action :start
  ignore_failure true # required for the first cluster build
end

etcd_key '/test' do
  value 'test_value'
  action :set
end
