#/bin/sh
#RAILS_ENV=production bundle exec rake assets:precompile
#unicorn_rails -c config/unicorn.rb -E production -D
sudo systemctl start parrashop
