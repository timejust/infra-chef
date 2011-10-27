#
# Cookbook Name:: monit
# Recipe:: server
#
# Description: M/Monit expand upon Monit's capabilities to provide monitoring and management of all Monit enabled hosts from one easy to use web-interface.
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

## create directory
directory "#{node[:monit][:server][:deploy_to]}" do
  mode    0755
  owner   "root"
  group   "root"
  action  :create
end

## Download m-monit
remote_file "/tmp/mmonit-#{node[:monit][:server][:version]}-#{node[:monit][:server][:package]}.tar.gz" do
  source "http://#{node[:monit][:server][:url]}/mmonit-#{node[:monit][:server][:version]}-#{node[:monit][:server][:package]}.tar.gz"
  mode "0644"
end

## Install m-monit
bash "Install m-monit" do
  cwd "/tmp"
  code <<-EOH
  tar -vxf mmonit-#{node[:monit][:server][:version]}-#{node[:monit][:server][:package]}.tar.gz -C #{node[:monit][:server][:deploy_to]}
  EOH
  not_if { File.exists?("#{node[:monit][:server][:deploy_to]}/mmonit-#{node[:monit][:server][:version]}") }
end