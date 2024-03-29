#
# Cookbook Name:: tool
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

include_recipe "apt"


node.run_state[:tools] = []

search(:tools) do |tool|
  (tool["server_roles"] & node.run_list.roles).each do |tool_role|
    node.run_state[:tools] << {:tool => tool, :recipes => tool["type"][tool_role]}
  end
end

node.run_state[:tools].map {|a| a[:recipes]}.flatten.each do |recipe|
  ## Do this so that different databaags with the same recipe can run
  node.run_state[:seen_recipes].delete("tool::#{recipe}")
  include_recipe "tool::#{recipe}"
end


node.run_state.delete(:tools)

