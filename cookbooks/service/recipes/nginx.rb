#
# Cookbook Name:: service
# Recipe:: default
#
# Copyright 2012, Timejust SA,
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

include_recipe "nginx::source"
    
## Do SSL only things
#if ssl
#  template "#{node[:nginx][:dir]}/sites-available/#{app['id']}-ssl.conf" do
#    source "nginx/#{app['id']}.conf.erb"
#    owner "root"
#    group "root"
#    mode "0644"
#    variables(
#      :app => app['id'],
#      :docroot => "/var/www/#{app['id']}/current",
#      :server_name => app['site'][node.app_environment]['hostname'] ? app['site'][node.app_environment]['hostname'] : "#{node[:fqdn]}",
#      :server_aliases => [ node[:fqdn], app['id'] ],
#      :environment => app['site'][node.app_environment]['environment'],
#      :port => "443",
#      :set_real_ip_from => app['site'][node.app_environment]['set_real_ip_from'],
#      :ssl => ssl,
#      :ssl_crt => "#{app['id']}-server.crt",
#      :ssl_key => "#{app['id']}-server.key"
#    ) 
#  end
  
#  ruby_block "write_crt" do
#    block do
#      f = File.open("/etc/ssl/#{app['id']}-server.crt", "w")
#      f.print( app['site'][node.app_environment]['ssl_crt'])
#      f.close
#    end
#    not_if do File.exists?("/etc/ssl/#{app['id']}-server.crt"); end
#  end

#  file "/etc/ssl/#{app['id']}-server.crt" do
#    owner "root"
#    group "root"
#    mode '0600'
#  end

#  ruby_block "write_key" do
#    block do
#      f = File.open("/etc/ssl/#{app['id']}-server.key", "w")
#      f.print( app['site'][node.app_environment]['ssl_key'])
#      f.close
#    end
#    not_if do File.exists?("/etc/ssl/#{app['id']}-server.key"); end
#  end

#  file "/etc/ssl/#{app['id']}-server.key" do
#    owner "root"
#    group "root"
#    mode '0600'
#  end
#end

#if ssl
#  nginx_site "#{app['id']}-ssl.conf" do
#  end
#end
  
## Setup monitoring
%w(
    nginx_memory
    nginx_request
    nginx_status
  ).each do |plugin_name|
    munin_plugin plugin_name do
      plugin "#{plugin_name}#{node[:ipaddress].gsub('.','_')}"
      create_file true
    end
  end



