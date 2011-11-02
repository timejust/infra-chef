#
# Cookbook Name:: datastore
# Recipe:: redis
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
  next unless current_datastore[:recipes].include? "redis"

  datastore = current_datastore[:datastore]

  node.default[:redis][:max_memory]     = node[:memory][:total].to_i / 2

  node.default[:redis][:version]        = datastore['configuration'][node.app_environment][:version]
  node.default[:redis][:source]         = "http://redis.googlecode.com/files/redis-#{node.default[:redis][:version]}.tar.gz"
  node.default[:redis][:dir]            = "/opt/redis-#{node.default[:redis][:version]}"
  node.default[:redis][:port]           = datastore['configuration'][node.app_environment][:port]
  node.default[:redis][:databases]      = datastore['configuration'][node.app_environment][:databases]
  node.default[:redis][:timeout]        = datastore['configuration'][node.app_environment][:timeout]
  node.default[:redis][:bind_address]   = datastore['configuration'][node.app_environment][:listen]
  node.default[:redis][:loglevel]       = datastore['configuration'][node.app_environment][:loglevel]

  include_recipe "redis"

  ## Setup monitoring
  cpan_module "IO::Socket::INET"
  cpan_module "Switch"
  cpan_module "Redis"

  #%w(
  #    connected_clients
  #    per_sec
  #    used_memory
  #  ).each do |plugin|
  #    munin_plugin "redis_" do
  #      plugin      "redis_#{plugin}"
  #      create_file true
  #    end
  #  end
  
  #munin_plugin "redis_speed" do
  #  plugin      "redis_speed"
  #  create_file true
  #end
end  
