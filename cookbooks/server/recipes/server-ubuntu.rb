#
# Cookbook Name:: server
# Recipe:: server-ubuntu
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

node.run_state[:servers].each do |current_server|
  next unless current_server[:recipes].include? "server-ubuntu"

  servers = current_server[:servers]
  
  include_recipe "perl"
  include_recipe "munin::client"
  
  ## remove some default plugins
  bash "remove iostat plugin from munin" do
    cwd "/etc/munin/plugins"
    code <<-EOH
      rm -f iostat
      rm -f iostat_ios
    EOH
    only_if { File.exists?("/etc/munin/plugins/iostat") }
  end
      
   %w(
        sshd_log
      ).each do |plugin_name|
        munin_plugin plugin_name do
          plugin "#{plugin_name}"
          create_file true
          conf_file true
        end
      end   
  
  include_recipe "monit"
  # include_recipe "zerigo"
 
  # The following bashes ensure there will be no issue with open files
  bash "set fs.file-max = 70000 in /etc/sysctl.conf" do
    user "root"
    code <<-EOH
    echo 'fs.file-max = 70000' >> /etc/sysctl.conf
    EOH
    not_if { `cat /etc/sysctl.conf`.include? "fs.file-max" }
  end

  bash "set soft and hard limits in /etc/security/limits.conf" do
    user "root"
    code <<-EOH
    echo -e 'www-data soft nofile 10240\\nwww-data hard nofile 65536\\ntomcat soft nofile 10240\\ntomcat hard nofile 65536\\nroot soft nofile 10240\\nroot hard nofile 65536' >> /etc/security/limits.conf
    EOH
    not_if { `cat /etc/security/limits.conf`.include? "tomcat" }
  end

  bash "ulimit -n 65536" do
    user "root"
    code <<-EOH
    ulimit -n 65536
    EOH
  end
  
end  
