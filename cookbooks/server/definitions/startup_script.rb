#
# Author:: Adam Jacob <adam@opscode.com>
# Cookbook Name:: server
# Definition:: startup_script
# Description:: Creates an init.d startup script for a service
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
# 

define :startup_script, :service => Hash.new, :environment => "development", :cookbook => nil do
  
  template "/etc/init.d/#{params[:name]}" do
    source  "startup/#{params[:service][:id]}.erb"
    owner   "root"
    group   "root"
    mode    "0755"
    cookbook "#{params[:cookbook]}"
    variables(
      :service =>     params[:service],
      :environment => params[:environment]
    )
  end

  bash "register startup" do 
    user "root"
    code <<-EOH
      update-rc.d #{params[:name]} defaults
    EOH
    not_if { File.exists?("/etc/init.d/#{params[:name]}") }  
  end
end
