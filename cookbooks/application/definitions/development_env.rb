#
# Cookbook Name:: application
# Definition:: development_env
#
# Description:  Runs the modifications necessary to create the development environment
#
#  

define :development_env, :deploy_to => nil, :owner => "deploy", :group => "deploy"  do
  # Copy database.yml
  #bash "copy_database.yml #{params[:deploy_to]}" do
  #  cwd "#{params[:deploy_to]}"
  #  code <<-EOH
  #    cp shared/database.yml current/config
  #  EOH
  #end
  
  # Create tmp directories for unicorn due to the permission difference
  # between the deploy users and leeloo
  %w(cache pids sessions sockets).each do |dir|
    directory "#{params[:deploy_to]}/current/tmp/#{dir}" do
      owner       params[:owner]
      group       params[:group]
      mode      '0755'
      recursive true
    end
  end
end