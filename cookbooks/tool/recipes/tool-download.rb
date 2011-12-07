#
# Cookbook Name:: tool
# Recipe:: tool-download
#
# Description: Install timejust download server

node.run_state[:tools].each do |current_tool|
  next unless current_tool[:recipes].include? "tool-download"

  tool = current_tool[:tool]

  include_recipe "apt"
  
  package "nginx package" do
     package_name "nginx"
     action :install
  end

  service "nginx" do
    supports :status => true, :restart => true, :reload => true
    action [ :enable, :start ]
  end
  
  service "nginx" do
    action :start
  end
end