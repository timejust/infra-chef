maintainer       "Alex Soto"
maintainer_email "apsoto@gmail.com"
license          "Apache 2.0"
description      "Configures monit.  Originally based off the 37 Signals Cookbook."
version          "0.5"

supports "debian"
supports "ubuntu"

recipe "monit", "Default recipe for installing default system monitoring parameters"
recipe "monit::client", "Instlls monit and configures a client"

attribute 'monit/notify_email', 
  :description => 'The email address to send alerts to.',
  :type => "string",
  :required => "recommended"

attribute 'monit/poll_period',
  :description => 'How often to perform checks (in seconds)',
  :type => "string",
  :required => "recommended"

attribute 'monit/poll_start_delay',
  :description => 'When monit first starts, how long to delay before it starts performing checks',
  :type => "string",
  :required => "recommended"

