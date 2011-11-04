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
# Creates Linux Users
#

define :user_authorized_keys, :owner => "leeloo", :group => "leeloo", :key => "KEY HERE" do
  
  directory "/home/#{params[:owner]}/.ssh" do
    owner params[:owner]
    group params[:group]
    mode '0755'
    recursive true
    not_if do File.exists?("/home/#{params[:owner]}/.ssh"); end
  end
  
  file "/home/#{params[:owner]}/.ssh/authorized_keys" do
    owner params[:owner]
    group params[:group]
    not_if do File.exists?("/home/#{params[:owner]}/.ssh/authorized_keys"); end
  end
  
  
  ruby_block "open_authorized_keys" do
    block do
      f = File.open("/home/#{params[:owner]}/.ssh/authorized_keys", "a")
      f.puts("#{params[:key]}")
      f.close
    end
    not_if do 
      system("grep \"#{params[:key]}\" /home/#{params[:owner]}/.ssh/authorized_keys")
    end
  end
end
