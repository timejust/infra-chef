#
# Cookbook Name:: application
# Recipe:: app-hudson
#
# Description: Install the archiva, Artifact Repository Manager

node.run_state[:tools].each do |current_tool|
  next unless current_tool[:recipes].include? "tool-hudson"

  tool = current_tool[:tool]

  node.default[:hudson][:server][:user] = tool[:owner]
  node.default[:hudson][:server][:port] = tool[:port]
  node.default[:hudson][:server][:home] = tool[:deploy_to]

  include_recipe "java"
  include_recipe "hudson"
  
  service "hudson" do
    action :start
  end
  
  ## Create ssh key so hudson can pull from github 
  directory "#{node[:hudson][:server][:home]}/.ssh" do
    action :create
    mode 0755
    owner tool[:owner]
  end
  
  ruby_block "hudson_deploy_keys" do
    block do
      f = File.open("#{tool[:deploy_to]}/.ssh/id_rsa", "w")
      f.puts("#{tool[:deploy_key]}")
      f.close
    end
  end
  
  bash "change permissions" do
    user "root"
    code <<-EOH
      chown #{tool[:owner]} #{tool[:deploy_to]}/.ssh/id_rsa
      chmod 0600 #{tool[:deploy_to]}/.ssh/id_rsa
    EOH
  end  
    
  ## Create ssh forwarding so hudson can use its key to pull from git remotely
  cookbook_file "#{tool[:deploy_to]}/.ssh/config" do
    source      "#{tool[:id]}/config"
    owner       tool[:owner]
    mode        0600
  end 
  
  ## Force configuration changes to configuration 
  template "/etc/default/hudson" do
    source      "tool-hudson/hudson.erb"
    owner       "root"
    group       "root"
    mode        0644
    variables(
      :owner => tool[:owner],
      :deploy_to => tool[:deploy_to],
      :port => tool[:port]
    )
    notifies :restart, resources(:service => "hudson")
  end 
end