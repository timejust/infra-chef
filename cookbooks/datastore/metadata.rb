maintainer       "timejust.com"
maintainer_email "minsik.kim@timejust.com"
license          "Apache 2.0"
description      "Installs/Configures datastore"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.1"

recipe           "datastore", "Loads datastores databags and selects recipes to use"
recipe           "datastore::redis", "Installs Redis"
recipe           "datastore::mongodb", "Installs Mongodb"

%w{ redis mongodb }.each do |cb|
  depends cb
end

