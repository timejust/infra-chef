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
  next unless current_service[:recipes].include? "service-geo"

  service = current_service[:service]
    
  # Create .prop file
  # template "#{node[:jetty][:home]}/conf/#{node.app_environment}.app.props" do
  #   path        "#{node[:jetty][:home]}/resources/#{node.app_environment}.app.props"
  #   source      "service-geo/service.props.erb"
  #   owner       "root"
  #   group       "root"
  #   mode        0644
  #   variables   :props => service['props'][node.app_environment]
  # end
  
  scala_version = "#{service['build'][node.app_environment]['scala']}"
  service_version = "#{service['build'][node.app_environment]['service']}"

  if node.app_environment == "development"
    war = "#{service['deploy_to']}/target/scala_#{scala_version}/#{service['id']}_#{scala_version}-#{service_version}.war"
  else
    war = "#{service['deploy_to']}/current/target/scala_#{scala_version}/#{service['id']}_#{scala_version}-#{service_version}.war"
  end
  
  execute "unzip jetty-hightide-8.0.0.RC0.tar.gz" do
    user "root"
    command "cd /tmp/ && tar xzf jetty-hightide-8.0.0.RC0.tar.gz"
  end
  
  ### Deploy the war
  bash "cp #{war} #{node[:jetty][:webapp_dir]}" do
    code <<-EOH 
    cp #{war} #{node[:jetty][:webapp_dir]}/#{service['id']}.war
    EOH
  end
  
  execute "change ownership" do
    user "root"
    command "chown #{node[:jetty][:group]}:#{node[:jetty][:user]} #{node[:jetty][:webapp_dir]}/#{service['id']}.war"
  end
end