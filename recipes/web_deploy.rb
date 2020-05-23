
include_recipe 'nodejs'

# Recipe should install npm, but ensure it does
apt_package 'npm'
