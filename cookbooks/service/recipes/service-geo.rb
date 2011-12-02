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

  war_file = "#{service['id']}_#{scala_version}-#{service_version}.war"
  if node.app_environment == "development"
    war = "#{service['deploy_to']}/target/scala_#{scala_version}/#{war_file}"
  else
    war = "#{service['deploy_to']}/current/target/scala_#{scala_version}/#{war_file}"
  end
    
  ### Deploy the war
  bash "ln -sf #{war} #{node[:jetty][:webapp_dir]}/#{service['id']}.war" do
    code <<-EOH 
    ln -sf #{war} #{node[:jetty][:webapp_dir]}/#{service['id']}.war
    EOH
  end
  
  execute "change ownership" do
    user "root"
    command "chown #{node[:jetty][:group]}:#{node[:jetty][:user]} #{node[:jetty][:webapp_dir]}/#{service['id']}.war"
  end
end