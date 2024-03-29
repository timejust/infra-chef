maintainer       "timejust.com"
maintainer_email "minsik.kim@timejust.com"
license          "Apache 2.0"
description       "Installs Ruby 1.9.2 from source"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version           "1.0"

%w( apt build-essential ).each do |d|
  depends d
end

recipe            "ruby-1.9.2", "Installs Ruby 1.9.2 from source."
