#
# Cookbook Name:: sbt
# Recipe:: default
#
# Copyright 2011, Timejust SA
#
# All rights reserved - Do Not Redistribute
#
## Install java
include_recipe "java"

bash "create sbt folder" do
  not_if do File.exists?("/usr/local/lib/sbt") end
  code <<-EOH
    mkdir -p /usr/local/lib/sbt
  EOH
end

sbt_remote_url = "http://typesafe.artifactoryonline.com/typesafe/ivy-releases/org.scala-tools.sbt/sbt-launch/#{node['sbt']['version']}/sbt-launch.jar"

if node['sbt']['version'] == "0.7.7"
  sbt_remote_url = "http://simple-build-tool.googlecode.com/files/sbt-launch-0.7.7.jar"
end

remote_file "/usr/local/lib/sbt/sbt-launch-#{node['sbt']['version']}.jar" do
  source sbt_remote_url
  mode 0644
  action :create_if_missing
  not_if { `ls -l /usr/local/lib/sbt`.include? "sbt-launch-#{node['sbt']['version']}.jar" }
end


# For some reason this jar is not downloaded by sbt
# remote_file "/root/.m2/repository/junit/junit/4.0/junit-4.0.jar" do
#   source "http://typesafe.artifactoryonline.com/internal/junit/junit/3.8.1/junit-3.8.1.jar"
#   mode 0644
#   action :create_if_missing
# end

file "/usr/bin/sbt" do
  owner node['owner']
  group node['group']
  mode  0755
  content <<-EOH
#!/bin/sh
# sbt run script

# Is the location of the SBT launcher JAR file.
LAUNCHJAR="/usr/local/lib/sbt/sbt-launch-#{node['sbt']['version']}.jar"

# Ensure enough heap space is created for SBT.
if [ -z "$JAVA_OPTS" ]; then
  JAVA_OPTS="-Xmx512M -Xms256M -XX:MaxPermSize=256m -Xss2M -Dfile.encoding=UTF8"
fi

# Assume java is already in the shell path.
exec java $JAVA_OPTS -jar "$LAUNCHJAR" "$@"
  EOH
end