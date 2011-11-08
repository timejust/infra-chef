#
# Cookbook Name:: munin
# Recipe:: server
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

include_recipe "munin::client"
include_recipe "lighttpd"

package "munin"

cookbook_file "/etc/cron.d/munin" do
  source "munin-cron"
  mode "0644"
  owner "root"
  group "root"
  backup 0
end

munin_servers = search(:node, "hostname:[* TO *] AND role:#{node[:app_environment]}")

Chef::Log.info("Munin SERVER environment monitoring: #{munin_servers.count}")

if node[:public_domain]
  case node[:app_environment]
  when "production"
    public_domain = node[:public_domain]
  else
    public_domain = "#{node[:app_environment]}.#{node[:public_domain]}"
  end
else
  public_domain = node[:domain]
end

template "/etc/munin/munin.conf" do
  source "munin.conf.erb"
  mode 0644
  variables(:munin_nodes => munin_servers)
end

bash "move_munin_dir" do
  user "root"
  code <<-EOH
    mv /var/cache/munin/www/ /var/www/munin
    chown munin.munin -R /var/www/munin
  EOH
end

template "/etc/munin/munin-node.conf" do
  source "munin-node.conf.erb"
  mode 0644
  variables :munin_servers => munin_servers
  notifies :restart, resources(:service => "munin-node")
end


