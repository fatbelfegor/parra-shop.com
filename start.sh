#/bin/sh
unicorn_rails -c config/unicorn.rb -E production -D
