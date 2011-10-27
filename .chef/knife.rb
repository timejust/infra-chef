log_level                :info
log_location             STDOUT
node_name                'timejust'
client_key               '/etc/chef/timejust.pem'
validation_client_name   'timejust-validator'
validation_key           '/etc/chef/validation.pem'
chef_server_url          'http://chef.timejust.com:4000'
cache_type               'BasicFile'
cache_options( :path => "#{ENV['HOME']}/.chef/checksums" )
cookbook_path            ["cookbooks"]
cookbook_copyright       "timejust.com"
cookbook_email           "minsik.kim@timejust.com"
cookbook_license         "apachev2"
