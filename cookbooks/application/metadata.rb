maintainer       "Opscode, Inc."
maintainer_email "cookbooks@opscode.com"
license          "Apache 2.0"
description      "Deploys and configures a variety of applications defined from databag 'apps'"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.99.12"
recipe           "application", "Loads application databags and selects recipes to use"
recipe           "application::nginx", "Install Nginx"
recipe           "application::java_webapp", "Deploys a Java web application WAR specified in a data bag with the remote_file resource"
recipe           "application::mod_php_apache2", "Sets up a deployed PHP application as a mod_php virtual host in Apache2"
recipe           "application::php", "Deploys a PHP application specified in a data bag with the deploy_revision resource"
recipe           "application::rails", "Deploys a Rails application specified in a data bag with the deploy_revision resource"
recipe           "application::tomcat", "Sets up the deployed Java application with Tomcat as the servlet container"
recipe           "application::thin", "Sets up the deployed Rails application with Thin as the web server"
recipe           "application::users", "Sets up the users to deploy the application"

%w{ apt ruby php apache2 runit thin user deploy nginx java monit hudson logrotate }.each do |cb|
  depends cb
end
