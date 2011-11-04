#
# Cookbook Name:: application
# Recipe:: default
#
# Copyright 2009, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe "deploy"
include_recipe "apt"

# Do things necessary for the development environment
if node.app_environment == "development" 
  # set hosts if in development
  bash "change hostname" do
    code <<-EOH
      sudo bash
      echo app-web.local > /etc/hostname
      hostname -b -F /etc/hostname
    EOH
  end
end

node.run_state[:apps] = []

search(:apps) do |app|
  (app["server_roles"] & node.run_list.roles).each do |app_role|
    if node.app_environment == "development" 
      app['owner'] = "leeloo"
      app['group'] = "leeloo"
    end
    node.run_state[:apps] << {:app => app, :recipes => app["type"][app_role]}
  end
end

node.run_state[:apps].map {|a| a[:recipes]}.flatten.each do |recipe|
  ## Do this so that different databaags with the same recipe can run
  node.run_state[:seen_recipes].delete("application::#{recipe}")
  #Chef::Log.info("include_recipe application::#{recipe}")
  include_recipe "application::#{recipe}"
end


node.run_state.delete(:apps)

