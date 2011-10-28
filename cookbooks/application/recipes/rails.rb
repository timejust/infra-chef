#
# Cookbook Name:: application
# Recipe:: default
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

node.run_state[:apps].each do |current_app|
  next unless current_app[:recipes].include? "rails"

  app = current_app[:app]

  ###
  # You really most likely don't want to run this recipe from here - let the
  # default application recipe work it's mojo for you.
  ###

  # Are we using REE?
  use_ree = false
  if node.run_state[:seen_recipes].has_key?("ruby_enterprise")
    use_ree = true
  end

  node.default[:apps][app['id']][node.app_environment][:run_migrations] = false

  ## First, install any application specific packages
  if app['packages']
    app['packages'].each do |pkg,ver|
      package pkg do
        action :install
        version ver if ver && ver.length > 0
      end
    end
  end

  ## Next, install any application specific gems
  if app['gems']
    app['gems'].each do |gem,ver|
      if use_ree
        ree_gem gem do
          action :install
          version ver if ver && ver.length > 0
          not_if "sleep 10000", :timeout => 900
        end
      else
        gem_package gem do
          action :install
          version ver if ver && ver.length > 0
          not_if "sleep 10000", :timeout => 900
        end
      end
    end
  end

  ## Setup the standardized deployment directories and keys
  deploy_setup app['deploy_to'] do
    owner       app['owner']
    group       app['group']
    deploy_key  app['deployment'][node.app_environment]['deploy_key']
    directories ['log','pids','sockets', 'system']
  end
   
  if app["database_master_role"]
    dbm = nil
    # If we are the database master
    if node.run_list.roles.include?(app["database_master_role"][0])
      dbm = node
    else
      # Find the database master
      results = search(:node, "run_list:role\\[#{app["database_master_role"][0]}\\] AND app_environment:#{node[:app_environment]}", nil, 0, 1)
      rows = results[0]
      if rows.length == 1
        dbm = rows[0]
      end
    end
   
    if dbm.nil? && node[:app_environment] == "development" 
      Chef::Log.warn("No node with role #{app["database_master_role"][0]}, database.yml not rendered!")
    end
   
    template "#{app['deploy_to']}/shared/database.yml" do
      source "database.yml.erb"
      owner app["owner"]
      group app["group"]
      mode "644"
      variables(
        :databases => app['databases']
      )
    end
  end
  
  if app["memcached_role"]
    results = search(:node, "role:#{app["memcached_role"][0]} AND app_environment:#{node[:app_environment]} NOT hostname:#{node[:hostname]}")
    if results.length == 0
      if node.run_list.roles.include?(app["memcached_role"][0])
        results << node
      end
    end
    template "#{app['deploy_to']}/shared/memcached.yml" do
      source "memcached.yml.erb"
      owner app["owner"]
      group app["group"]
      mode "644"
      variables(
        :memcached_envs => app['memcached'],
        :hosts => results.sort_by { |r| r.name }
      )
    end
  end
  

  ## Then do the initial, deploy
  deploy app['id'] do
    not_if        { node.app_environment == "development"}
    revision      app['revision'][node.app_environment]
    repository    app['repository']
    user          app['owner']
    group         app['group']
    deploy_to     app['deploy_to']
    environment   'RAILS_ENV' => node.app_environment
    action        app['force'][node.app_environment] ? :force_deploy : :deploy
    ssh_wrapper   "#{app['deploy_to']}/.deploy/deploy-ssh-wrapper" if app['deployment'][node.app_environment]['deploy_key']
    symlinks      "system" => "public/system", "log" => "log"
   
    enable_submodules app['has_submodules'] ? true : false
                
    before_migrate do
      if app['gems'].has_key?('bundler')
        execute "bundle install" do
          cwd release_path
          user "root"
          group "root"
          ignore_failure true
        end
      end  
    end
   
    symlink_before_migrate({
      "database.yml" => "config/database.yml"
    })
   
    if app['migrate'][node.app_environment] && node[:apps][app['id']][node.app_environment][:run_migrations]
      migrate true
      migration_command "rake db:migrate"
    else
      migrate false
    end
  
    before_restart do
      if node.app_environment && app['databases'].has_key?(node.app_environment)
        Chef::Log.warn("Running after_migrate")
        # Install Gems
        if app['gems'].has_key?('bundler')
          execute "bundle install" do
            cwd release_path
            user "root"
            group "root"
            ignore_failure true
          end
        end
          
        # Make sure to generate the sass with jammit
        execute "rake sass:update" do
          only_if { system("find #{app['deploy_to']} -name *.sass | grep 'sass'") }
          cwd release_path
          ignore_failure true
          user      app['owner']
          group     app['group']
        end
      end  
    end  
  end
  # 
  
  # Do things necessary for the development environment
  if node.app_environment == "development"
    Chef::Log.info("Do things necessary for the development environment #{app['id']}")
    # copy files to compensate for non capistrano type deploy in development
    development_env app['id'] do
      deploy_to app['deploy_to']
      owner     app['owner']
      group     app['group']
    end
  
    if app['gems'].has_key?('bundler')
      execute "bundle install" do
        cwd "#{app['deploy_to']}/current"
        user "root"
        group "root"
        ignore_failure true
      end
    end
  
    # grant for other machines to the db
    # grant app['id'] do
    #   host                "localhost"
    #   password            app['mysql_root_password']['development']
    #   user_to_grant       "root"
    #   location_to_grant   "%"
    #   identified_by       "sa"
    #   on                  "*.*"
    # end  
  
    #setup db schema
    # bash "#{app['id']}: rake db:setup RAILS_ENV=test" do
    #   cwd "#{app['deploy_to']}/current"
    #   code <<-EOH
    #     rake db:setup RAILS_ENV=test
    #     rake db:setup RAILS_ENV=cucumber
    #   EOH
    #   ignore_failure true
    # end
    
    #setup tests
    bash "setup spec #{app['id']}" do
      only_if { File.exists?("#{app['deploy_to']}/spec/spec.opts.example") }
      code <<-EOH
        cp #{app['deploy_to']}/spec/spec.opts.example #{app['deploy_to']}/spec/spec.opts
      EOH
    end
    
    # Make sure to generate the sass with jammit
    execute "rake sass:update" do
      only_if { system("find #{app['deploy_to']} -name *.sass | grep 'sass'")}
      cwd "#{app['deploy_to']}/current"
      ignore_failure true
      user     app['owner']
      group    app['group']
    end
    
    # we share a db so we no longer  run env reset:task
    # if node.app_environment == "development" && app['id'] == "app-web"
    #    #reset env
    #    bash "rake env:reset #{app['id']}" do
    #      not_if { File.exists?("#{app['deploy_to']}/.deploy/db_init.flag") }
    #      cwd "#{app['deploy_to']}/current"
    #      code <<-EOH
    #        rake env:reset
    #      EOH
    #      ignore_failure true
    #    end
    #  end
    
    ## Set marker db init
    file "#{app['deploy_to']}/.deploy/db_init.flag" do
      app['owner']
      app['group']
      mode '0600'
    end
  
  end 
   
  ## Create cronjob to free memory.
  cron "free_memory" do
    minute    "0"
    hour      "2"
    user      "root"
    command   "sync; echo 3 > /proc/sys/vm/drop_caches"
  end
  
  deploy_cleanup app['deploy_to'] 

end


