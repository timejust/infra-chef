maintainer       "timejust.com"
maintainer_email "minsik.kim@timejust.com"
license          "Apache 2.0"
description      "Installs/Configures queue"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.1"

recipe           "queue", "Loads queues databags and selects recipes to use"
recipe           "queue::rabbitmq", "Installs rabbitMQ"

%w{ resque  }.each do |cb|
  depends cb
end
