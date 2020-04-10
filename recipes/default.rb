#
# Cookbook:: sloeinfra
# Recipe:: default
#
# Copyright:: 2020, The Authors, All Rights Reserved.

file "#{ENV['HOME']}/sloeinfra_recipe_timestamp" do
  content Time.new.strftime("%Y-%m-%d %H:%M:%S\n")
end
