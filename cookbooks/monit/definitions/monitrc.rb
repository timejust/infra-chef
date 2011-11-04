#
# Cookbook Name:: monit
# Definition:: monitrc
#
# Copyright 2010, OpsCode, Inc.
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


define :monitrc, :options => Hash.new, :cookbook => "monit", :reload => :delayed do
  
  log "Making monitrc for: #{params[:name]}"
  template "/etc/monit/conf.d/#{params[:name]}.conf" do
    cookbook params[:cookbook]
    owner "root"
    group "root"
    mode 0644
    source "#{params[:name]}.conf.erb"
    
    if params[:options].respond_to?(:has_key?)
      variables :options => params[:options]
    end
    
    notifies :restart, resources(:service => "monit"), params[:reload]
    action :create
  end
  
end