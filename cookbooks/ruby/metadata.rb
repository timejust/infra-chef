maintainer       "timejust.com"
maintainer_email "minsik.kim@timejust.com"
license          "Apache 2.0"
description      "Installs/Configures ruby"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.1"

recipe "ruby", "Installs ruby packages"

%w{ centos redhat fedora ubuntu debian arch}.each do |os|
  supports os
end

