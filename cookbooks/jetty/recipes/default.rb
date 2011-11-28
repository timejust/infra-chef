#
# Cookbook Name:: jetty
# Recipe:: default
#
# Copyright 2011, Timejust SA.
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

include_recipe "java"

remote_file "/tmp/jetty-hightide-8.0.0.RC0.tar.gz" do
  source "http://dist.codehaus.org/jetty/jetty-hightide-8.0.0.RC0/jetty-hightide-8.0.0.RC0.tar.gz"
  mode 0644
  owner "root"
  group "root"
  action :create_if_missing
end

execute "unzip jetty-hightide-8.0.0.RC0.tar.gz" do
  user "root"
  command "cd /tmp/ && tar xzf jetty-hightide-8.0.0.RC0.tar.gz"
end

jetty_user = node['jetty']['user']
jetty_group = node['jetty']['group']
jetty_home = node["jetty"]["home"]
jetty_log = node["jetty"]["log_dir"]

execute "install jetty-hightide-8.0.0.RC0" do
  command "sudo cp jetty-hightide-8.0.0.RC0/bin/jetty.sh /etc/init.d/jetty && sudo mkdir -p #{jetty_home} && sudo cp -R jetty-hightide-8.0.0.RC0/* #{jetty_home}/"
end

include_recipe "user"

user_create "#{jetty_group} #{jetty_user}" do
  owner jetty_user
  group jetty_group
  uid   1012
  gid   1012
  comment "jetty user create"
end
  
#execute "create user(#{jetty_user}) and group" do
#  user "root"
#  command "sudo useradd #{jetty_user}"
#end
#sudo groupadd #{jetty_group}

execute "change group and owner" do
  user "root"
  command "sudo chown -R #{jetty_group}:#{jetty_user} #{jetty_home}"
end

execute "change permissions" do
  user "root"
  command "sudo chmod -R ugo+rw #{jetty_home} && sudo mkdir -p #{jetty_log} && sudo chown jetty #{jetty_log} -R"
end

template "/etc/default/jetty" do
  source "default_jetty.erb"
  owner "root"
  group "root"
  mode "0644"
end

service "jetty" do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end

execute "update init script" do
  user "root"
  command "sudo update-rc.d jetty defaults"
  notifies :restart, resources(:service => "jetty")
end

