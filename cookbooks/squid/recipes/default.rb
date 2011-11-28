#
# Cookbook Name:: squid
# Recipe:: default
#
# Copyright 2011, Timejust.com
#
# All rights reserved - Do Not Redistribute
#
package "squid package" do
   package_name "squid"
   action :install
end

service "squid" do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end


