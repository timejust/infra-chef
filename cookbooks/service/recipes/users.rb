#
# Cookbook Name:: service
# Recipe:: default
#
# Copyright 2011, Timejust SA
#
# All rights reserved - Do Not Redistribute
#

node.run_state[:services].each do |current_service|
  next unless current_service[:recipes].include? "users"

  service = current_service[:service]
  
  include_recipe "user"

  unless node.app_environment == "development"
    user_create "deploy user" do
      owner service['owner']
      group service['group']
      uid 1002
      gid 1002
      comment "Service deploy user"
    end
    
    user_sudoer "deploy user" do
      owner   service['owner']
      comment "Service deploy user"
    end  
    
    if service.has_key?("authorized_keys") 
      user_authorized_keys "deploy user" do
        owner   service['owner']
        group   service['group']
        key     service['authorized_keys'][node.app_environment]['key']
      end
    end    
  end
end