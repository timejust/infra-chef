#
# Cookbook Name:: munin
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

package "munin-node"
package "munin-java-plugins"
package "munin-plugins-extra"

## Create log directory
directory "/var/log/munin" do  
  mode        0755
  recursive   true
  not_if { File.exists?("/var/log/munin") }
end

service "munin-node" do
  supports :restart => true
  action :enable
end

munin_servers = search(:node, "role:monitoring-munin")

template "/etc/munin/munin-node.conf" do
  source "munin-node.conf.erb"
  mode 0644
  variables :munin_servers => munin_servers
  notifies :restart, resources(:service => "munin-node")
end
