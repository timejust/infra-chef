#
# Cookbook Name:: deploy
# Definition:: deploy_cleanup
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

define :deploy_cleanup do

  directory "#{params[:name]}/.deploy" do
    action :delete
  end
  
end

