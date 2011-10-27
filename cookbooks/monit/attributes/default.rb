default[:monit][:notify_email]           = "administrator@smartdate.com"

default[:monit][:poll_period]            = 60
default[:monit][:poll_start_delay]       = 120

default[:monit][:mail_format][:subject]  = "$ACTION $SERVICE $EVENT"
default[:monit][:mail_format][:from]     = "monit@smartdate.com"
default[:monit][:mail_format][:message]    = <<-EOS

Yo,

Date:    $DATE
Action:  $ACTION
Service: $SERVICE
Host:    $HOST
Event:   $EVENT

$DESCRIPTION

Yours sincerely,

monit
EOS

default[:monit][:server][:url]     = "www.mmonit.com/dist"
default[:monit][:server][:package] = "linux-x64"
default[:monit][:server][:version] = "2.3.4"
default[:monit][:server][:deploy_to] = "/opt/mmonit"

default[:monit][:server][:username] = "monit"
default[:monit][:server][:password] = "monit"
default[:monit][:server][:port]     = 8080