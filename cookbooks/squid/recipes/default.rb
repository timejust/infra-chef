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
   notifies :start, resources(:service => "squid"), :immediately
end