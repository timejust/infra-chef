#
# Cookbook Name:: nginx
# Recipe:: source
#
# Author:: Adam Jacob (<adam@opscode.com>)
# Author:: Joshua Timberman (<joshua@opscode.com>)
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

include_recipe "build-essential"

unless platform?("centos","redhat","fedora")
  include_recipe "runit"
end

packages = value_for_platform(
    ["centos","redhat","fedora"] => {'default' => ['pcre-devel', 'openssl-devel']},
    "default" => ['libpcre3', 'libpcre3-dev', 'libssl-dev', 'geoip-bin', 'libgeoip-dev', 'libgeoip1']
  )

packages.each do |devpkg|
  package devpkg
end

nginx_version = node[:nginx][:version]
configure_flags = node[:nginx][:configure_flags].join(" ")
node.set[:nginx][:daemon_disable] = true

remote_file "/tmp/nginx-#{nginx_version}.tar.gz" do
  source "http://nginx.org/download/nginx-#{nginx_version}.tar.gz"
  action :create_if_missing
end

# Additional modules.
remote_file "/tmp/nginx-upstream-jvm-route-#{node[:nginx][:jvm_route_version]}.tar.gz" do
  source "http://nginx-upstream-jvm-route.googlecode.com/files/nginx-upstream-jvm-route-#{node[:nginx][:jvm_route_version]}.tar.gz"
  action :create_if_missing
end
 
Chef::Log.info("******************* raw ./configure #{node[:nginx][:configure_flags]}")
Chef::Log.info("******************* ./configure #{configure_flags}")

bash "compile_nginx_source" do  
  cwd "/tmp"
  code <<-EOH
    tar zxf nginx-#{nginx_version}.tar.gz
    tar zxf nginx-upstream-jvm-route-#{node[:nginx][:jvm_route_version]}.tar.gz
    cd nginx-#{nginx_version}
    patch -p0 < ../nginx_upstream_jvm_route/jvm_route.patch
    ./configure #{configure_flags} --add-module=../nginx_upstream_jvm_route
    make && make install
  EOH
  creates node[:nginx][:src_binary]
end

directory node[:nginx][:log_dir] do
  mode 0755
  owner node[:nginx][:user]
  action :create
end

## logroate

logrotate_app "nginx" do
  path        "#{node[:nginx][:log_dir]}/*.log"
  postrotate  "/etc/init.d/nginx restart"
  rotate      30
  frequency   "daily"
  create      "644 root root"
end

directory node[:nginx][:dir] do
  owner "root"
  group "root"
  mode "0755"
end

%w{ sites-available sites-enabled conf.d }.each do |dir|
  directory "#{node[:nginx][:dir]}/#{dir}" do
    owner "root"
    group "root"
    mode "0755"
  end
end

%w{nxensite nxdissite}.each do |nxscript|
  template "/usr/sbin/#{nxscript}" do
    source "#{nxscript}.erb"
    mode "0755"
    owner "root"
    group "root"
  end
end

template "nginx.conf" do
  path "#{node[:nginx][:dir]}/nginx.conf"
  source "nginx.conf.erb"
  owner "root"
  group "root"
  mode "0644"
end

cookbook_file "#{node[:nginx][:dir]}/mime.types" do
  source "mime.types"
  owner "root"
  group "root"
  mode "0644"
end

# install stub-status server for monitoring
template "#{node[:nginx][:dir]}/sites-available/stub-status.conf" do
  Chef::Log.info("Nginx monitoring")
  source "stub-status.conf.erb"
  owner "root"
  group "root"
  mode "0644"
end


unless platform?("centos","redhat","fedora")
  runit_service "nginx"

  service "nginx" do
    supports :status => true, :restart => true, :reload => true
    subscribes :restart, resources(:bash => "compile_nginx_source")
    subscribes :restart, resources(:template => "nginx.conf")
    subscribes :restart, resources(:cookbook_file => "#{node[:nginx][:dir]}/mime.types")
  end
  
  nginx_site "stub-status.conf" do
    notifies :restart, resources(:service => "nginx")
  end
  
else
  #install init db script
  template "/etc/init.d/nginx" do
    source "nginx.init.erb"
    owner "root"
    group "root"
    mode "0755"
  end

  #install sysconfig file (not really needed but standard)
  template "/etc/sysconfig/nginx" do
    source "nginx.sysconfig.erb"
    owner "root"
    group "root"
    mode "0644"
  end

  #register service
  service "nginx" do
    action :enable
    subscribes :restart, resources(:bash => "compile_nginx_source")
  end
end
