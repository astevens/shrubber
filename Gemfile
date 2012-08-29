source :rubygems

# Padrino Stable Gem
gem 'padrino', '0.10.7'

# Project requirements
gem 'rake'
gem 'sinatra-flash', :require => 'sinatra/flash'

# Component requirements
gem 'haml'

gem 'dm-mysql-adapter'
gem 'dm-validations'
gem 'dm-timestamps'
gem 'dm-migrations'
# gem 'dm-constraints'
gem 'dm-aggregates'
gem 'dm-is-tree'
gem 'dm-core'

gem 'mechanize'

# Test requirements
group :test do
  gem 'rspec', :group => "test"
  gem 'rack-test', :require => "rack/test", :group => "test"
  gem 'debugger'
  gem 'database_cleaner'
  # database cleaner is set to use transactions
  gem 'dm-transactions'
end

group :development do
  gem 'heroku'
  gem 'debugger'
  gem 'thin' # or mongrel
end