node.run_state[:apps].each do |current_app|
  next unless current_app[:recipes].include? "app-web-alpha"

  app = current_app[:app]
  redis = app['redis']
  urls = app['urls']
  gapps = app['gapps']
 
  template "#{app['deploy_to']}/current/config/configatron_data/redis_and_co.yml" do
    source "app-web-alpha/redis_and_co.yml.erb"
    owner app["owner"]
    group app["group"]
    mode "644"
    variables(
      :redis => redis
    )
  end

  template "#{app['deploy_to']}/current/config/configatron_data/urls.yml" do
    source "app-web-alpha/urls.yml.erb"
    owner app["owner"]
    group app["group"]
    mode "644"
    variables(
      :urls => urls
    )
  end

  template "#{app['deploy_to']}/current/config/configatron_data/gapps.yml" do
    source "app-web-alpha/gapps.yml.erb"
    owner app["owner"]
    group app["group"]
    mode "644"
    variables(
      :gapps => gapps
    )
  end

 # create place for pids
  directory "#{app['deploy_to']}/current/tmp/pids" do
    owner app['owner']
    group app['group']
    mode '0755'
  end

  # restart resque pool
  bash "#{app['id']}: bundle exec rake resque:pool:restart RAILS_ENV=#{node.app_environment}" do
    cwd "#{app['deploy_to']}/current"
    code <<-EOH
      bundle exec rake resque:pool:stop RAILS_ENV=#{node.app_environment}
      bundle exec rake resque:pool:start RAILS_ENV=#{node.app_environment}
    EOH
    ignore_failure true
  end

  service "#{app[:id]}" do
    action :restart
    ignore_failure true
  end

end


