
include_recipe 'sloeinfra::web_dev'

include_recipe 'vagrant'

vagrant 'Vagrant' do
  version node['vagrant']['version']
end
