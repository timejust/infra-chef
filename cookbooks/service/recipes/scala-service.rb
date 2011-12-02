#
# Cookbook Name:: service
# Recipe:: default
#
# Copyright 2011, Timejust SA
#
# All rights reserved - Do Not Redistribute
#

node.run_state[:services].each do |current_service|
  next unless current_service[:recipes].include? "scala-service"

  service = current_service[:service]

  ## First, install any application specific packages
  if service['packages']
    service['packages'].each do |pkg,ver|
      package pkg do
        action :install
        version ver if ver && ver.length > 0
      end
    end
  end

  ## Next, install any application specific gems
  if service['gems']
    service['gems'].each do |gem,ver|
      gem_package gem do
        action :install
        version ver if ver && ver.length > 0
        #not_if "sleep 10000", :timeout => 900
      end
    end
  end

  ## Install java
  node.default[:java][:install_flavor] = service['java']['install_flavor']
  node.default[:java][:java_home] = service['java']['java_home']
  include_recipe "java"
  
  ## Install sbt
  node.default[:sbt][:version] = "0.7.7"
  node.default[:owner] = service['owner']
  node.default[:group] = service['group']
  include_recipe "sbt"
  
  ## Setup the standardized deployment directories and keys
  deploy_setup service['deploy_to'] do
    owner       service['owner']
    group       service['group']
    deploy_key  service['deployment'][node.app_environment]['deploy_key']
  end
  
  include_recipe "jetty"
  
  ## Then, deploy
  deploy service['id'] do
    not_if      { node.app_environment == "development"}
    branch      service['revision'][node.app_environment]
    repository  service['repository']
    user        service['owner']
    group       service['group']
    deploy_to   service['deploy_to']
    action      service['force'][node.app_environment] ? :force_deploy : :deploy
    ssh_wrapper "#{service['deploy_to']}/.deploy/deploy-ssh-wrapper" if service['deployment'][node.app_environment]['deploy_key']
  
    symlink_before_migrate "" => ""
    symlinks  "" => ""
    before_restart do            
      # Build the war
      bash "sbt clean update package" do
        #execute "sbt clean update package" do
        Chef::Log.info("sbt clean update package")   
        cwd "#{service['deploy_to']}/current"                     
        code <<-EOH
        sbt clean update package
        EOH
      end
    end  
  end
  
  if node.app_environment == "development"
    # Build the war
    bash "#{service['deploy_to']}/ sbt clean update package" do
      #execute "sbt clean update package" do
      Chef::Log.info("#{service['deploy_to']}/ sbt clean update package")   
      cwd "#{service['deploy_to']}/"                     
      code <<-EOH
      sbt clean update package
      EOH
    end
  end
  
  ## Create log directory for the service
  directory "/var/log/#{service['id']}" do
    owner       node[:jetty][:user]
    group       node[:jetty][:user]  
    mode        '0755'
    recursive   true
  end  

  deploy_cleanup service['deploy_to'] 
end