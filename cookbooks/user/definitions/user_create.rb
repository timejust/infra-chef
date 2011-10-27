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
# Creates Linux Users
#

define :user_create, :owner => "leeloo", :group => "leeloo", :gid => 1001, :uid => 1001, :comment => "User to save the universe" do
  
  Chef::Log.info("user_create #{params[:owner]} #{params[:owner]}")
  # Create groups, users, etc
  group params[:group] do
    gid params[:gid]
    ignore_failure true
  end

  user params[:owner] do
    comment params[:comment]
    uid params[:uid]
    gid params[:gid]
    home "/home/#{params[:owner]}"
    shell "/bin/bash"
    ignore_failure true
  end

  directory "/home/#{params[:owner]}" do
    mode 0755
    owner params[:owner]
    group params[:group]
    ignore_failure true
  end

end

