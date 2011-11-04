#
# Cookbook Name:: application
# Definition:: access_list
#
# Description:  Creates an nginx access restriction list based on ip's
#
# Limitations:  Currently there can only be one access list per nginx server 

define :access_list do
  
  directory "#{node[:nginx][:dir]}/access_lists" do
    owner       "root"
    group       "root"
    mode        0755
    recursive   true
  end

  cookbook_file "#{node[:nginx][:dir]}/access_lists/#{params[:access_list]}" do
    source      "#{params[:access_list]}"
    cookbook    "application"
    owner       "root"
    group       "root"
    mode        0644
    notifies :restart, resources(:service => "nginx")
  end
  
  # Add ip ranges configuration 
  template "#{node[:nginx][:dir]}/conf.d/#{params[:name]}-access.conf" do
    source      "#{params[:name]}/#{params[:name]}-access.conf.erb"
    owner       "root"
    group       "root"
    mode        0644
    variables(
      :access_list => params[:access_list]
    )
    notifies :restart, resources(:service => "nginx")
  end
  
end
