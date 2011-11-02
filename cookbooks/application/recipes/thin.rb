#
# Cookbook Name:: application
# Recipe:: thin 
#
# Copyright 2011, timejust.com
##
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

node.run_state[:apps].each do |current_app|
  next unless current_app[:recipes].include? "thin"

  app = current_app[:app]

  include_recipe "thin"

  # create place for pids
  directory "/var/run/#{app['id']}" do
    owner app['owner']
    group app['group']
    mode '0755'
  end
  
  # create place for logs
  directory "/var/log/#{app['id']}" do
    owner app['owner']
    group app['group']
    mode '0755'
  end

  # create place for socket
  directory "/tmp/#{app['id']}" do
    owner app['owner']
    group app['group']
    mode '0755'
  end

  ## logroate
  logrotate_app "#{app['id']}" do
    path        "/var/log/#{app['id']}/*.log"
    postrotate  "/etc/init.d/#{app['id']} restart"
    rotate      7
    frequency   "weekly"
    create      "644 #{app['owner']} #{app['group']}"
  end

  bash "install thin" do
    code <<-EOH
      thin install
    EOH
  end

  thin = app['thin'][node.app_environment]
 
  # Write thin configuration yml 
  template "/etc/thin/#{app['id']}.yml" do
    source "thin/thin.yml.erb"
    owner "root"
    group "root"
    mode 0644
    variables :name => app['id'],
              :timeout => thin['timeout'],
              :port => thin['port'],
              :log_path => "#{app['id']}_out.log",
              :max_conns => thin['max_conns'],
              :environment => node.app_environment,
              :servers => app['site'][node.app_environment]['num_upstream'],
              :deploy_to => app['deploy_to'] 
  end

  # Write thin startup script
  template "/etc/init.d/#{app['id']}" do
    source  "startup/app-thin.erb"
    owner   "root"
    group   "root"
    mode    "0755"
    variables(
      :app_name => app['id']
    )
  end

  bash "register startup" do 
    user "root"
    code <<-EOH
      update-rc.d #{app['id']} defaults
    EOH
    not_if { File.exists?("/etc/init.d/#{app['id']}") }  
  end

  #if File.exists?(File.join(app['deploy_to'], "current"))
  #  d = resources(:deploy => app['id'])
  #  d.restart_command do
  #    execute "/etc/init.d/#{app['id']} restart"
  #  end
  #end


  ## Setup monitoring  
 # %w(
 #     thin_status
 #   ).each do |plugin_name|
 #     munin_plugin plugin_name do
 #       plugin "#{plugin_name}#{node[:ipaddress].gsub('.','_')}"
 #       create_file true
 #       use_template true
 #       options(:rails_root =>File.join(app['deploy_to'], 'current'), :pid_file => node.default[:thin][:pid])
 #     end
 #   end
end

