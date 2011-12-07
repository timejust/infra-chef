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
  
  # Create service config file
  template "#{node[:jetty][:home]}/resources/#{service['id']}.conf" do
    path        "#{node[:jetty][:home]}/resources/#{service['id']}.conf"
    source      "service-geo/service-geo.conf.erb"
    owner       "jetty"
    group       "jetty"
    mode        0644
    variables   :akka => service[:akka][node.app_environment], 
                :google => service[:google][node.app_environment], 
                :geo_database => service[:geo_databases][node.app_environment]
  end
    
  # Replace jetty.conf file with customized conf file.
  template "#{node[:jetty][:home]}/etc/jetty.conf" do
    path        "#{node[:jetty][:home]}/etc/jetty.conf"
    source      "service-geo/jetty.conf.erb"
    owner       "jetty"
    group       "jetty"
    mode        0644
    variables   :akka_conf => "#{node[:jetty][:home]}/resources/#{service['id']}.conf"
  end
  
  scala_version = "#{service['build'][node.app_environment]['scala']}"
  service_version = "#{service['build'][node.app_environment]['service']}"

  war_file = "#{service['id']}_#{scala_version}-#{service_version}.war"
  if node.app_environment == "development"
    war = "#{service['deploy_to']}/target/scala_#{scala_version}/#{war_file}"
  else
    war = "#{service['deploy_to']}/current/target/scala_#{scala_version}/#{war_file}"
  end
    
  ### Deploy the war
  bash "cp #{node[:jetty][:webapp_dir]}/#{service['id']}.war #{war}" do
    code <<-EOH 
    cp #{node[:jetty][:webapp_dir]}/#{service['id']}.war #{war} 
    EOH
  end
  
  execute "change ownership" do
    user "root"
    command "chown #{node[:jetty][:group]}:#{node[:jetty][:user]} #{node[:jetty][:webapp_dir]}/#{service['id']}.war"
  end
end