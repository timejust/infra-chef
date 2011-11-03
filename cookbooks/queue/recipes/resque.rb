#
# Cookbook Name:: queue
# Recipe:: resque
#
# Configures and install resque service

node.run_state[:queues].each do |current_queue|
  next unless current_queue[:recipes].include? "resque"

  queue = current_queue[:queue]
  #Chef::Log.info("*********************#{queue['gems']}")

  node.default[:resque][:gems] = queue['gems']
  node.default[:resque][:redis_server] = queue['configuration'][node.app_environment]['redis_server']
  node.default[:resque][:frontend][:dir]  = queue['deploy_to']
  node.default[:resque][:frontend][:owner]  = queue['owner']
  node.default[:resque][:frontend][:group]  = queue['group']

  include_recipe "resque"
  
  # This is necessary for the moment because of the fact that resque is installing gems we don't want
  ##bash "remove_extra_gems" do
  #  only_if { system("gem list | grep 'rack' | grep '1.2.1'") }
  #  user "root"
  #  code <<-EOH
  #    gem uninstall rack -v="1.2.1"
  #    gem uninstall vegas  
  #  EOH
  #  ignore_failure true
  #end
  
end

