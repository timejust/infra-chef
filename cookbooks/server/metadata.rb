maintainer       "timejust.com"
maintainer_email "minsik.kim@timejust.com"
license          "Apache 2.0"
description      "Installs/Configures server"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.1"

recipe           "server", "Loads servers databags and selects recipes to use"
recipe           "server::ubuntu", "Setups up based ubuntu box"

%w{ apt ntp perl munin monit java vsftpd user}.each do |cb|
  depends cb
end
