maintainer       "Timejust SA"
maintainer_email "minsik.kim@timejust.com"
license          "All rights reserved"
description      "Installs/Configures service"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.1"
recipe           "service", "Loads service databags and selects recipes to use"
recipe           "service::users", "Sets up the users to deploy the application"
recipe           "service::nginx", "Installs Nginx"
recipe           "service::scala-service", "Installs scala service environment"

%w{ deploy user nginx runit jetty java server sbt }.each do |cb|
  depends cb
end

