
include_recipe 'vagrant'

vagrant 'Vagrant' do
  version node['vagrant']['version']
end
