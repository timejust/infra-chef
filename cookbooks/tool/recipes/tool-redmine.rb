#
# Cookbook Name:: tool
# Recipe:: tool-redmine
#
# Description: Install redmine server

node.run_state[:tools].each do |current_tool|
  next unless current_tool[:recipes].include? "tool-redmine"

  tool = current_tool[:tool]
  
  node.default[:redmine][:version] = tool[:redmine][:version]
  node.default[:redmine][:dl_id] = tool[:redmine][:dl_id]
  node.default[:redmine][:db][:hostname] = "bug.timejust.com"
  node.default[:apache][:listen_ports] = [ "8090","443" ]
  
  include_recipe "redmine"
  
  service "apache2" do
    action :restart
  end
end