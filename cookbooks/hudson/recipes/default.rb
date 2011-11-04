#
# Author:: Doug MacEachern <dougm@vmware.com>
# Cookbook Name:: hudson
# Recipe:: default
#
# Copyright 2010, VMware, Inc.
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

#include_recipe "java"

home = node[:hudson][:server][:home]
pkey = "#{home}/.ssh/id_rsa"

package "daemon" do
  action :install
end

service "hudson" do
  action :nothing
end

node[:hudson][:server][:plugins].each do |name|
  remote_file "#{node[:hudson][:server][:home]}/plugins/#{name}.hpi" do
    source "#{node[:hudson][:mirror]}/latest/#{name}.hpi"
    owner node[:hudson][:server][:user]
    group node[:hudson][:server][:user]    
  end
end

bash "install_hudson" do
  cwd "/tmp"
  code <<-EOH
  wget -O /tmp/key http://hudson-ci.org/debian/hudson-ci.org.key
  sudo apt-key add /tmp/key
  wget -O /tmp/hudson.deb http://hudson-ci.org/latest/debian/hudson.deb
  sudo dpkg --install /tmp/hudson.deb
  EOH
end

user node[:hudson][:server][:user] do
  action :modify
  home node[:hudson][:server][:home]
end

directory "#{node[:hudson][:server][:home]}/.ssh" do
  action :create
  mode 0700
  owner node[:hudson][:server][:user]
end

pid_file = "/var/run/hudson.pid"
#restart if this run only added new plugins
service "hudson" do
  only_if do
    if File.exists?(pid_file)
      htime = File.mtime(pid_file)
      Dir["#{node[:hudson][:server][:home]}/plugins/*.hpi"].select { |file|
        File.mtime(file) > htime
      }.size > 0
    end
  end
  action :stop
end

service "hudson" do
  action :start
  only_if { true }
end

#hudson_job "test" do
#  action :create
#  config "config.xml"
#end
