#
# Cookbook Name:: service
# Recipe:: service-api
# Description: API Services for mobile and desktop 
#              This recipe setups up nginx as a revers proxy to all of the 
#              various services.  

# Copyright 2012, Timejust SA.
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

node.run_state[:services].each do |current_service|
  next unless current_service[:recipes].include? "service-api"

  service = current_service[:service]

  ## Do explicitly so we know what we are dealing with
  v1_services = service[:services][:v1]
  #v2_services = service[:services][:v2]
  #
  #v2_services.each do |name,data|
  #  data['servers'] = node[:app_environment] != "development" ? search(:node, "role:#{data['id']} AND app_environment:#{node[:app_environment]}") : [ServiceStub.new]
  #end

  v1_services.each do |name,data|
    data['servers'] = node[:app_environment] != "development" ? search(:node, "role:#{data['id']} AND app_environment:#{node[:app_environment]}") : [ServiceStub.new]
  end  
    
  ## Create configuration files for nginx external proxy
  ## This is necessary for the external access to the api
  template "#{node[:nginx][:dir]}/sites-available/#{service['id']}.conf" do
    source "nginx/#{service['id']}-nginx.conf.erb"
    owner "root"
    group "root"
    mode "0644"
    variables(  :v1_services => v1_services,
                :port => service[:nginx][:port][:api],
                :set_real_ip_from => service['site'][node.app_environment]['set_real_ip_from'] )
    notifies :restart, resources(:service => "nginx")            
  end

  nginx_site "#{service['id']}.conf" do
    notifies :restart, resources(:service => "nginx")
  end
  
  ## Create directory for the load balancer ping
  directory "/var/www/#{service['id']}" do
    owner       service['owner']
    group       service['group']
    mode        '0755'
    recursive   true
  end

  ## add crossdomain
  #cookbook_file "/var/www/#{service['id']}/load-balancer-check.json" do
  #  source      "api/load-balancer-check.json"
  #  owner       service['owner']
  #  group       service['group']
  #  mode        0644
  #end
    
  # Rate limit access to port 80
  #bash "update iptables (eth0 port 80 - 20 hits per 60 seconds)" do
  #  user "root"
  #  code <<-EOH
	#iptables -A INPUT -p tcp --dport 80 -j ACCEPT --source 10.234.253.209
	#iptables -I INPUT -p tcp --dport 80 -i eth0 -m state --state NEW -m recent --set
	#iptables -I INPUT -p tcp --dport 80 -i eth0 -m state --state NEW -m recent --update --seconds 60 --hitcount 20 -j DROP
  #  EOH
  #  not_if { `iptables -L`.include? "60 hit_count" }
  #end

  
  ## Setup monitoring
  %w(
      nginx_memory
      nginx_request
      nginx_status
    ).each do |plugin_name|
      munin_plugin plugin_name do
        plugin "#{plugin_name}#{node[:ipaddress].gsub('.','_')}"
        create_file true
      end
    end
  
end