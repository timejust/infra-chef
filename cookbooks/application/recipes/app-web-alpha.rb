node.run_state[:apps].each do |current_app|
  next unless current_app[:recipes].include? "app-web-alpha"

  app = current_app[:app]
  redis = app['redis'][node[:app_environment]]
  urls = app['urls'][node[:app_environment]]
  gapps = app['gapps'][node[:app_environment]]
 
  template "#{app['deploy_to']}/current/config/configatron_data/redis_and_co.yml" do
    source "app-web-alpha/redis_and_co.yml.erb"
    owner app["owner"]
    group app["group"]
    mode "644"
    variables(
      :host => redis['host'],
      :port => redis['port'],
      :namespace => redis['namespace'],
      :resque_namespace => redis['resque_namespace'], 
      :environment => node[:app_environment]
    )
  end

  template "#{app['deploy_to']}/current/config/configatron_data/urls.yml" do
    source "app-web-alpha/urls.yml.erb"
    owner app["owner"]
    group app["group"]
    mode "644"
    variables(
      :urls => urls,
      :environment => node[:app_environment]
    )
  end

  template "#{app['deploy_to']}/current/config/configatron_data/gapps.yml" do
    source "app-web-alpha/gapps.yml.erb"
    owner app["owner"]
    group app["group"]
    mode "644"
    variables(
      :gapps => gapps,
      :environment => node[:app_environment]
    )
  end

  service "#{app[:id]}" do
    action :restart
    ignore_failure true
  end

end


