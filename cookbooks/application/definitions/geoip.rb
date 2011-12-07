#
# Cookbook Name:: application
# Definition:: geoip
#
# Description:  Setup geoip database for use in the geoip module
#

define :geoip do

  directory "#{params[:geoip_database_location]}" do
    owner       "root"
    group       "root"
    mode        0755
    recursive   true
  end

  # get the application
  remote_file "/tmp/GeoIPCity.dat.tar.gz" do
    source "http://download.timejust.com/GeoIPCity.dat.tar.gz"
    mode "0644"
    owner "root"
    group "root"
    not_if { File.exists?("/tmp/GeoIPCity.dat.tar.gz") }
  end
  
  bash "untar GeoIPCity" do
    cwd "/tmp"
    user "root"
    code <<-EOH
      tar -zxf GeoIPCity.dat.tar.gz
      mv GeoIPCity.dat #{params[:geoip_database_location]}/#{params[:geoip_database]}
      chown root:root #{params[:geoip_database_location]}/#{params[:geoip_database]}
    EOH
    creates "#{params[:geoip_database_location]}/#{params[:geoip_database]}"
  end
  
  # Add ip ranges configuration 
  template "#{node[:nginx][:dir]}/conf.d/#{params[:name]}-geoip.conf" do
    source      "#{params[:name]}/#{params[:name]}-geoip.conf.erb"
    owner       "root"
    group       "root"
    mode        0644
    variables(
      :geoip_database_location => params[:geoip_database_location],
      :geoip_database => params[:geoip_database]
    )
    notifies :restart, resources(:service => "nginx")
   end
  
end