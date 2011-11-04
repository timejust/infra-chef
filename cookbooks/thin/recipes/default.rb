include_recipe "ruby"
include_recipe "rubygems"

gem_package "thin" do
  #version node[:thin][:version]
  action :install
end
