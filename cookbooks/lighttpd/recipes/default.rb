#
# Cookbook Name:: lighthttp
# Recipe:: default
#
# Copyright 2010, Smartdate SA
#
# All rights reserved - Do Not Redistribute
#

package "lighttpd"

service "lighttpd" do
  action :start
  only_if { true }
end