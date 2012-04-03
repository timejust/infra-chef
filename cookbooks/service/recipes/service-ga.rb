#
# Cookbook Name:: service
# Recipe:: default
#
# Copyright 2011, Timejust SA
#
# All rights reserved - Do Not Redistribute
#

include_recipe "deploy"
include_recipe "apt"

node.run_state[:services].each do |current_service|
  next unless current_service[:recipes].include? "service-ga"

  service = current_service[:service]
  
  scala_version = "#{service['build'][node.app_environment]['scala']}"
  service_version = "#{service['build'][node.app_environment]['service']}"

  war_file = "#{service['id']}_#{scala_version}-#{service_version}.war"
  if node.app_environment == "development"
    war = "#{service['deploy_to']}/target/scala_#{scala_version}/#{war_file}"
  else
    war = "#{service['deploy_to']}/current/target/scala_#{scala_version}/#{war_file}"
  end
    
  ### Deploy the war
  bash "cp #{war} #{node[:jetty][:webapp_dir]}/#{service['id']}.war" do
    code <<-EOH 
    cp #{war} #{node[:jetty][:webapp_dir]}/#{service['id']}.war 
    EOH
  end
  
  execute "change ownership" do
    user "root"
    command "chown #{node[:jetty][:group]}:#{node[:jetty][:user]} #{node[:jetty][:webapp_dir]}/#{service['id']}.war"
  end
end