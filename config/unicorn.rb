worker_processes 2
working_directory "/home/ikishik/parra-shop.com"

preload_app true

timeout 1000

listen "0.0.0.0:3070", :backlog => 64

pid "/home/ikishik/parra-shop.com/tmp/pids/unicorn.pid"

stderr_path "/home/ikishik/parra-shop.com/log/unicorn.stderr.log"
stdout_path "/home/ikishik/parra-shop.com/log/unicorn.stdout.log"

before_fork do |server, worker|
    defined?(ActiveRecord::Base) and
        ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|
    defined?(ActiveRecord::Base) and
        ActiveRecord::Base.establish_connection
end