#
# Cookbook Name:: monit
# Recipe:: client
#
# Copyright 2010, Opscode, Inc.
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

package "monit" do
  action :remove
  not_if { system("monit -V | grep 5.2") }
end

bash "Update repo for monit" do
  code <<-EOH
  sudo add-apt-repository ppa:sjinks/x3m
  apt-get update
  EOH
  ignore_failure true
  not_if { system("monit -V | grep 5.2") }
end

package "monit" do
  action :install
end

Chef::Log.info("#{node[:platform_version]}")

if platform?("ubuntu")
  if "#{node[:platform_version]}".include?("10.")
    cookbook_file "/etc/default/monit" do
      source "monit.default"
      owner "root"
      group "root"
      mode 0644
    end
  end
  
  if "#{node[:platform_version]}".include?("11.")
    cookbook_file "/etc/default/monit" do
      source "monit-11.04.default"
      owner "root"
      group "root"
      mode 0644
    end
  end
    
end

service "monit" do
  action :start
  enabled true
  supports [:start, :restart, :stop]
end

monitserver = search(:node, "role:monitoring-m-monit")

begin
  if monitserver.empty?
    monitserver = "localhost"
  else
    monitserver = monitserver.first[:ipaddress]
  end
rescue Exception => e
  monitserver = "localhost"
end   

template "/etc/monit/monitrc" do
  owner "root"
  group "root"
  mode 0700
  source 'monitrc.erb'
  variables :ipaddress => node[:ipaddress],
            :monitserver => monitserver
  notifies :restart, resources(:service => "monit"), :immediate
end
