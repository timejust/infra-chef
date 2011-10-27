#
# Cookbook Name:: server
# Recipe:: default
#
# Copyright 2011, timejust.com
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
node.run_state[:servers] = []

search(:servers) do |server|
  (server["server_roles"] & node.run_list.roles).each do |role|
    node.run_state[:servers] << {:server => server, :recipes => server["type"][role]}
  end
end

node.run_state[:servers].map {|a| a[:recipes]}.flatten.uniq.each do |recipe|
  include_recipe "server::#{recipe}"
end

node.run_state.delete(:servers)
