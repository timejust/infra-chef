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

node.run_state[:apps].each do |current_app|
  next unless current_app[:recipes].include? "nginx"

  app = current_app[:app]

  #ssl = !(app['site'][node.app_environment]['ssl_crt'].nil?)

  node[:nginx][:configure_flags] = [
      "--prefix=#{node[:nginx][:install_path]}",
      "--conf-path=#{node[:nginx][:dir]}/nginx.conf",
      "--with-http_ssl_module",
      "--with-http_gzip_static_module",
      "--with-http_realip_module",
      "--with-http_stub_status_module",
      "--with-http_geoip_module"
    ]
  
  include_recipe "nginx::source"
  
  Chef::Log.info("Installing Nginx Configuration for #{app['id']}")
  
  template "#{node[:nginx][:dir]}/sites-available/#{app['id']}.conf" do
    source "nginx/#{app['id']}.conf.erb"
    owner "root"
    group "root"
    mode "0644"
    variables(
      :num_upstream => app['site'][node.app_environment]['num_upstream'],
      :app => app['id'],
      :docroot => "/var/www/#{app['id']}/current",
      :server_name => app['site'][node.app_environment]['hostname'] ? app['site'][node.app_environment]['hostname'] : "#{node[:fqdn]}",
      :server_aliases => [ node[:fqdn], app['id'] ],
      :environment => app['site'][node.app_environment]['environment'],
      :port => app['site'][node.app_environment]['port'],
      :set_real_ip_from => app['site'][node.app_environment]['set_real_ip_from'],
      :filename => app['filename'] ? app['filename'] : ""
    )
  end
  
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

  nginx_site "#{app['id']}.conf" do
  end
  
  #if ssl
  #  nginx_site "#{app['id']}-ssl.conf" do
  #  end
  #end
  
  ## Create application specific nginx.conf to allow for
  template "#{node[:nginx][:dir]}/nginx.conf" do
    source      "nginx.conf.erb"
    owner       "root"
    group       "root"
    mode        0644
    cookbook    "application"
  end
  
  # create restiction list
  if app['site'][node.app_environment]['access_list']
    access_list app['id']  do
      access_list app['site'][node.app_environment]['access_list']    
    end
  end
  
  # create plugin for using nginx geoip module
  if app['site'][node.app_environment]['use_geoip']
    geoip app['id'] do
      geoip_database_location       "/usr/share/GeoIP"
      geoip_database                "GeoIPCity.dat"
    end
  end
  
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
end


