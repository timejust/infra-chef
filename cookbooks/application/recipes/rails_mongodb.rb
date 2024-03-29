node.run_state[:apps].each do |current_app|
  next unless current_app[:recipes].include? "rails"

  app = current_app[:app]
  mongodb = app['mongodb']

  ## The passing of the services is temporary until
  ## the chat service can be modified to handled services and
  ## databases correctly, instead of simelataneously 
  template "#{app['deploy_to']}/shared/mongoid.yml" do
    source "mongoid.yml.erb"
    owner app["owner"]
    group app["group"]
    mode "644"
    variables(
      :mongodb => mongodb
    )
  end

  bash "create symlinks for mongoid.yml" do
    code <<-EOH
      ln -sf #{app['deploy_to']}/shared/mongoid.yml #{app['deploy_to']}/current/config/mongoid.yml
    EOH
    not_if { File.exists?("#{app['deploy_to']}/current/config/mongoid.yml") }
  end
end
