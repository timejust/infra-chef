#
# Cookbook Name:: mongodb
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

node.run_state[:datastores].each do |current_datastore|
  next unless current_datastore[:recipes].include? "mongodb"

  datastore = current_datastore[:datastore]

  node.default[:mongodb][:version]           = datastore['configuration'][node.app_environment][:version]
  node.default[:mongodb][:datadir]           = datastore['configuration'][node.app_environment][:data_dir]
  node.default[:mongodb][:dir]               = "/opt/mongodb-#{datastore['configuration'][node.app_environment][:version]}"
  node.default[:mongodb][:backup][:backupdir] = datastore['configuration'][node.app_environment][:backup_dir]
  
  include_recipe "mongodb::source"

  #%w(
  #     mongo_ops
  #     mongo_mem
  #     mongo_lock
  #     mongo_conn
  #     mongo_btree
  #   ).each do |plugin_name|
  #     munin_plugin plugin_name do
  #       plugin "#{plugin_name}"
  #       create_file true
  #     end
  #   end

end
