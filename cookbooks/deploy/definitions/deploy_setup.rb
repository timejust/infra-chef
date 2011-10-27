#
# Cookbook Name:: deploy
# Definition:: deploy_setup
#
# Description:: Creates a deploy for the git repository and stores it as id_deploy in the deploy_to directory
#               in a hidden directory .deploy
#
# Copyright 2008-2009, Opscode, Inc.
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

define :deploy_setup, :owner => 'root', :group => 'root', :directories => [], :deploy_key => nil do
    
  ## Setup directories
  directory params[:name] do
    owner       params[:owner]
    group       params[:group]
    mode        '0755'
    recursive   true
  end

  ## Initial deploy key for chef
  directory "#{params[:name]}/.deploy" do
    owner       params[:owner]
    group       params[:group]
    mode        '0755'
    recursive   true
  end

  directory "#{params[:name]}/shared" do
    owner       params[:owner]
    group       params[:group]
    mode        '0755'
    recursive   true
  end

  params[:directories].each do |dir|
    directory "#{params[:name]}/shared/#{dir}" do
      owner       params[:owner]
      group       params[:group]
      mode      '0755'
      recursive true
    end
  end
  
  ## Create deploy keys for initial deploy
  if params[:deploy_key]
    ruby_block "write_key" do
      block do
        f = File.open("#{params[:name]}/.deploy/id_deploy", "w")
        f.print("#{params[:deploy_key]}")
        f.close
      end
      not_if do File.exists?("#{params[:name]}/.deploy/id_deploy"); end
  end

    file "#{params[:name]}/.deploy/id_deploy" do
      owner     params[:owner]
      group     params[:group]
      mode      '0600'
    end

    template "#{params[:name]}/.deploy/deploy-ssh-wrapper" do
      source    "deploy-ssh-wrapper.erb"
      cookbook  "git"
      owner     params[:owner]
      group     params[:group]
      mode      '0755'
      variables :deploy_to => params[:name]
    end
  end  
end

