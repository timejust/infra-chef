node.run_state[:apps].each do |current_app|
  next unless current_app[:recipes].include? "app-web-alpha"

  app = current_app[:app]

  service "#{app[:id]}" do
    action :restart
    ignore_failure true
  end

end


