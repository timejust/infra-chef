#
# Cookbook Name:: application
# Recipe:: user
#
# Copyright 2011, Timejust.com
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

node.run_state[:tools].each do |current_tool|
  next unless current_tool[:recipes].include? "users"

  tool = current_tool[:tool]

  include_recipe "user"
  
  unless node.app_environment == "development"
    user_create "deploy user" do
      owner   tool['owner']
      group   tool['group']
      uid     1001
      gid     1001
      comment "Application deploy user"
    end

    user_sudoer "deploy user" do
      owner   tool['owner']
      comment "Application deploy user"
    end  
  end

  if tool['authorized_keys']
    user_authorized_keys "deploy user" do
      owner   tool['owner']
      group   tool['group']
      key     tool['authorized_keys'][node.app_environment]['key']
    end  
  end  

end

