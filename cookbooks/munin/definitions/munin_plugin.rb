#
# Cookbook Name:: munin
# Definition:: munin_plugin
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


define :munin_plugin, :plugin_config => "/etc/munin/plugins", :plugin_dir => "/usr/share/munin/plugins", :create_file => false, :conf_file => false, :enable => true, :options => Hash.new, :use_template => false do

  include_recipe "munin::client"

  plugin = params[:plugin] ? params[:plugin] : params[:name]

  if params[:create_file]
    if params[:use_template]
      template "#{params[:plugin_dir]}/#{params[:name]}" do
        source "#{params[:name]}.plugin.erb"
        owner "root"
        group "root"
        cookbook "munin"
        mode 0755
        if params[:options].respond_to?(:has_key?)
          variables :options => params[:options]
        end
      end  
    else
      cookbook_file "#{params[:plugin_dir]}/#{params[:name]}" do
        cookbook "munin"
        source "plugins/#{params[:name]}"
        owner "root"
        group "root"
        mode 0755
      end
    end  
  end

  link "#{params[:plugin_config]}/#{plugin}" do
    to "#{params[:plugin_dir]}/#{params[:name]}"
    if params[:enable]
      action :create
    else
      action :delete
    end
    notifies :restart, resources(:service => "munin-node")
  end
  
  if params[:conf_file]
    cookbook_file "/etc/munin/plugin-conf.d/#{params[:name]}" do
      cookbook "munin"
      source "plugin_conf/#{params[:name]}"
      owner "root"
      group "root"
      mode 0755
      notifies :restart, resources(:service => "munin-node")
    end
  end

end
