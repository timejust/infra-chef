#
# Cookbook Name:: service
# Recipe:: default
#
# Copyright 2011, Timejust SA
#
# All rights reserved - Do Not Redistribute
#

include_recipe "deploy"
include_recipe "server"

node.run_state[:services] = []

search(:services) do |service|
  (service["server_roles"] & node.run_list.roles).each do |service_role|
    node.run_state[:services] << {:service => service, :recipes => service["type"][service_role]}
  end
end

node.run_state[:services].map {|a| a[:recipes]}.flatten.uniq.each do |recipe|
  include_recipe "service::#{recipe}"
end

node.run_state.delete(:services)
