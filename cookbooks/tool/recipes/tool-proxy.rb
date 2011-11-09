#
# Cookbook Name:: tool
# Recipe:: tool-proxy
#
# Description: Install the http proxy server

node.run_state[:tools].each do |current_tool|
  next unless current_tool[:recipes].include? "tool-proxy"

  tool = current_tool[:tool]

  include_recipe "apt"
  include_recipe "squid"
  
  service "squid" do
    action :start
  end
  
  ## Force configuration changes to configuration 
  template "/etc/squid/squid.conf" do
    source      "tool-proxy/squid.conf.erb"
    owner       "root"
    group       "root"
    mode        0644
    variables(
      :port => tool[:port]
    )
    notifies :restart, resources(:service => "squid")
  end 
end