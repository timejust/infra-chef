maintainer        "thin"
maintainer_email  "sysadmins@37signals.com"
description       "Configures thin, a Ruby web server"
version           "0.1"
depends           "nginx"
depends           "apache2"
depends           "ruby"
depends           "rubygems"
recipe "thin", "Installs thin rubygem"

