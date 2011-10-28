#
# Cookbook Name:: application
# Recipe:: unicorn 
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

  ## logroate
  logrotate_app "#{app['id']}" do
    path        "/var/log/#{app['id']}/*.log"
    postrotate  "/etc/init.d/#{app['id']} restart"
    rotate      7
    frequency   "weekly"
    create      "644 #{app['owner']} #{app['group']}"
  end

  #node.default[:unicorn][:worker_timeout] = 60
  #node.default[:unicorn][:preload_app] = true
  #node.default[:unicorn][:worker_processes] = [node[:cpu][:total].to_i * 2, 8].min
  #node.default[:unicorn][:port] = "/var/run/#{app['id']}/unicorn.sock"
  #node.default[:unicorn][:pid] = "/var/run/#{app['id']}/unicorn-master.pid"

  #node.default[:unicorn][:stderr_path] = "/var/log/#{app['id']}/#{app['id']}-err.log"
  #node.default[:unicorn][:stdout_path] = "/var/log/#{app['id']}/#{app['id']}-out.log"

  #node.default[:unicorn][:before_fork] = <<-EOH
  #old_pid = '/var/run/#{app['id']}/unicorn-master.pid.oldbin'
  #  if File.exists?(old_pid) && server.pid != old_pid
  #    begin
  #      Process.kill("QUIT", File.read(old_pid).to_i)
  #    rescue Errno::ENOENT, Errno::ESRCH
  #      # someone else did our job for us
  #    end
  #  end
  #EOH

  #node.default[:unicorn][:after_fork] = <<-EOH
  #  #CHIMNEY.client.connect_to_server
  #  ActiveRecord::Base.establish_connection
  #  # Redis and Memcached would go here but their connections are established
  #  # on demand, so the master never opens a socket

    ##
    # Unicorn master is started as root, which is fine, but let's
    # drop the workers to something else
 #   begin
 #     uid, gid = Process.euid, Process.egid
 #     user, group = '#{app['owner']}', '#{app['group']}'
 #     target_uid = Etc.getpwnam(user).uid
 #     target_gid = Etc.getgrnam(group).gid
 #     worker.tmp.chown(target_uid, target_gid)
 #     if uid != target_uid || gid != target_gid
 #       Process.initgroups(user, target_gid)
 #       Process::GID.change_privilege(target_gid)
 #       Process::UID.change_privilege(target_uid)
 #     end
 #   rescue => e
 #     if RAILS_ENV == 'development'
 #       STDERR.puts "couldn't change user, oh well"
 #     else
 #       raise e
 #     end
 #   end
 # EOH

 # node.set[:unicorn][:options] = { :tcp_nodelay => true, :backlog => 100 }

 # unicorn_config "/etc/unicorn/#{app['id']}.rb" do
 #   listen({ node[:unicorn][:port] => node[:unicorn][:options] })
 #   working_directory File.join(app['deploy_to'], 'current')
 #   worker_timeout node[:unicorn][:worker_timeout] 
 #   preload_app node[:unicorn][:preload_app] 
 #   worker_processes node[:unicorn][:worker_processes]
 #   before_fork node[:unicorn][:before_fork]
 #   after_fork node[:unicorn][:after_fork]
 #   pid node.default[:unicorn][:pid]
 #   stderr_path node.default[:unicorn][:stderr_path]
 #   stdout_path node.default[:unicorn][:stdout_path]
 # end

 # unicorn_startup app['id'] do
 #   app_root      File.join(app['deploy_to'], 'current')
 #   environment   node.app_environment
 # end  
  
 # if File.exists?(File.join(app['deploy_to'], "current"))
 #  d = resources(:deploy => app['id'])
 #  d.restart_command do
 #    execute "/etc/init.d/#{app['id']} restart"
 #  end
 # end


  ## Setup monitoring  
  %w(
      thin_status
    ).each do |plugin_name|
      munin_plugin plugin_name do
        plugin "#{plugin_name}#{node[:ipaddress].gsub('.','_')}"
        create_file true
        use_template true
        options(:rails_root =>File.join(app['deploy_to'], 'current'), :pid_file => node.default[:thin][:pid])
      end
    end
end

