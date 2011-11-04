log_level                :info
log_location             STDOUT
node_name                'timejust'
client_key               '/timejust/code/infra-chef/.chef/timejust.pem'
validation_client_name   'chef-validator'
validation_key           '/etc/chef/validation.pem'
chef_server_url          'http://chef.timejust.com:4000'
cache_type               'BasicFile'
cache_options( :path => '/timejust/code/infra-chef/.chef/checksums' )
cookbook_path            ["cookbooks"]
