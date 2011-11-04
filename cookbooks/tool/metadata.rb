maintainer       "timejust.com"
maintainer_email "minsik.kim@timejust.com"
license          "Apache 2.0"
description      "Installs/Configures tool"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.1"

recipe           "tool::users", "Sets up the users to deploy the application"

%w{ apt runit user deploy nginx java monit hudson }.each do |cb|
  depends cb
end
