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
  next unless current_service[:recipes].include? "service-calendar"

  service = current_service[:service]
  
  # Create service config file
  template "#{node[:jetty][:home]}/resources/#{service['id']}.conf" do
    path        "#{node[:jetty][:home]}/resources/#{service['id']}.conf"
    source      "service-calendar/akka.conf.erb"
    owner       "jetty"
    group       "jetty"
    mode        0644
    variables   :akka => service[:akka][node.app_environment], 
                :google => service[:google][node.app_environment], 
                :redis => service[:redis][node.app_environment], 
                :calendar_database => service[:calendar_databases][node.app_environment]
  end
  
  # Replace start.ini file with customized conf file.
  template "#{node[:jetty][:home]}/start.ini" do
    path        "#{node[:jetty][:home]}/start.ini"
    source      "service-calendar/start.ini.erb"
    owner       "jetty"
    group       "jetty"
    mode        0644
    #variables   :akka_conf => "#{node[:jetty][:home]}/resources/#{service['id']}.conf"
    variables   :environment => node.app_environment
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