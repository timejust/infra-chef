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

define :user_sudoer, :owner => "leeloo", :comment => "leeloo user is a sudoer" do
  ruby_block "open_sudoer" do
    block do
      f = File.open("/etc/sudoers", "a")
      f.puts("# #{params[:comment]}")
      f.puts("#{params[:owner]} ALL=(ALL) NOPASSWD: ALL")
      f.close
    end
    not_if do 
      system("grep #{params[:owner]} /etc/sudoers")
    end
  end
end
