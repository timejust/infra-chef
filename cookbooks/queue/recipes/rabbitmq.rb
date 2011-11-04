#
# Cookbook Name:: queue
# Recipe:: rabbitmq
#
# Configures and install a java service in a tomcat container

node.run_state[:queues].each do |current_queue|
  next unless current_queue[:recipes].include? "rabbitmq"

  queue = current_queue[:queue]
  configuration = queue['configuration'][node.app_environment]
  ## First, install any application specific packages
  if queue['packages']
   queue['packages'].each do |pkg,ver|
     package pkg do
       action :install
       version ver if ver && ver.length > 0
     end
   end
  end
  
  remote_file "/tmp/rabbitmq-server_#{configuration[:version]}-1_all.deb" do
    source "http://www.rabbitmq.com/releases/rabbitmq-server/v#{configuration[:version]}/rabbitmq-server_#{configuration[:version]}-1_all.deb"
    mode 0644
  end
  
  bash "install rabbitmq" do
    cwd "/tmp"
    code <<-EOH
      dpkg -i rabbitmq-server_#{configuration[:version]}-1_all.deb
    EOH
    not_if { `ps -A -o command | grep "rabbitmq"`.include? "/var/lib/rabbitmq" }
  end
  
  #template "/etc/rabbitmq/rabbitmq.config" do
  #  source "rabbitmq/rabbitmq.config.erb"
  #  owner "root"
  #  group "root"
  #  mode 0644
  #  variables :port => configuration[:port],
  #            :address => configuration[:address],
  #            :nodename => "#{configuration[:nodename]}-#{node[:ipaddress].gsub('.','_')}"
  #  #notifies :restart, resources(:service => "rabbitmq-server")
  #end
  
  
  %w(
      rabbitmq-messages
      rabbitmq-connections
      rabbitmq-queue_memory
      rabbitmq-consumers
     ).each do |plugin|
       munin_plugin plugin do
         plugin      plugin
         conf_file   true
         create_file true
       end 
     end
     
   %w(
       rabbitmq_list_queues
      ).each do |plugin|
        munin_plugin plugin do
          plugin      plugin
          create_file true
        end 
      end
      
  # Plugins
  %w(
     mochiweb
     webmachine
     amqp_client
     rabbitmq-mochiweb
     rabbitmq-management-agent
     rabbitmq-management
    ).each do |plugin|
      remote_file "/usr/lib/rabbitmq/lib/rabbitmq_server-#{configuration[:version]}/plugins/#{plugin}-#{configuration[:version]}.ez" do
        source "http://www.rabbitmq.com/releases/plugins/v#{configuration[:version]}/#{plugin}-#{configuration[:version]}.ez"
        mode 0644
        not_if { File.exists?("/usr/lib/rabbitmq/lib/rabbitmq_server-#{configuration[:version]}/plugins/#{plugin}-#{configuration[:version]}.ez") }
      end
  end
     
end

