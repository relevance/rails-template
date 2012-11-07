# Application template recipe for the rails_apps_composer. Change the recipe here:
# https://github.com/RailsApps/rails_apps_composer/blob/master/recipes/gems.rb

### GEMFILE ###

## Ruby on Rails
insert_into_file 'Gemfile', "ruby '1.9.3'\n", :before => "gem 'rails', '3.2.6'" if prefer :deploy, 'heroku'

webserver_versions = {
  'thin' => '>= 1.5.0',
  'unicorn' => '>= 4.3.1',
  'puma' => '>= 1.6.3',
  'passenger' => '>= 3.0.17'
}

## Web Server
if (prefs[:dev_webserver] == prefs[:prod_webserver])
  gem prefs[:dev_webserver], webserver_versions[prefs[:dev_webserver]]
else
  gem prefs[:dev_webserver], webserver_versions[prefs[:dev_webserver]], :group => [:development, :test]
  gem prefs[:prod_webserver], webserver_versions[prefs[:prod_webserver]], :group => :production
end

## Database Adapter
gsub_file 'Gemfile', /gem 'sqlite3'\n/, '' unless prefer :database, 'sqlite'
gem 'pg', '>= 0.14.1' if prefer :database, 'postgresql'
gem 'mysql2', '>= 0.3.11' if prefer :database, 'mysql'

## Template Engine
if prefer :templates, 'haml'
  gem 'haml', '>= 3.1.7'
  gem 'haml-rails', '>= 0.3.5', :group => :development
  # hpricot and ruby_parser are needed for conversion of HTML to Haml
  gem 'hpricot', '>= 0.8.6', :group => :development
  gem 'ruby_parser', '>= 2.3.1', :group => :development
end
if prefer :templates, 'slim'
  gem 'slim', '>= 1.3.2'
  gem 'haml2slim', '>= 0.4.6', :group => :development
  # Haml is needed for conversion of HTML to Slim
  gem 'haml', '>= 3.1.6', :group => :development
  gem 'haml-rails', '>= 0.3.5', :group => :development
  gem 'hpricot', '>= 0.8.6', :group => :development
  gem 'ruby_parser', '>= 2.3.1', :group => :development
end

## Testing Framework
if prefer :unit_test, 'rspec'
  gem 'rspec-rails', '>= 2.11.0', :group => [:development, :test]
  gem 'capybara', '>= 1.1.2', :group => :test if prefer :integration, 'rspec-capybara'
  gem 'email_spec', '>= 1.2.1', :group => :test
end
if prefer :unit_test, 'minitest'
  gem 'minitest-spec-rails', '>= 3.0.7', :group => :test
  gem 'minitest-wscolor', '>= 0.0.3', :group => :test
  gem 'capybara', '>= 1.1.2', :group => :test if prefer :integration, 'minitest-capybara'
end
if prefer :integration, 'cucumber'
  gem 'cucumber-rails', '>= 1.3.0', :group => :test, :require => false
  gem 'database_cleaner', '>= 0.9.1', :group => :test
  gem 'launchy', '>= 2.1.2', :group => :test
  gem 'capybara', '>= 1.1.2', :group => :test
end
gem 'turnip', '>= 1.0.0', :group => :test if prefer :integration, 'turnip'
gem 'factory_girl_rails', '>= 4.1.0', :group => [:development, :test] if prefer :fixtures, 'factory_girl'
gem 'fabrication', '>= 2.3.0', :group => [:development, :test] if prefer :fixtures, 'fabrication'
gem 'machinist', '>= 2.0', :group => :test if prefer :fixtures, 'machinist'

## Email
gem 'sendgrid', '>= 1.0.1' if prefer :email, 'sendgrid'
gem 'hominid', '>= 3.0.5' if prefer :email, 'mandrill'

## Gems from a defaults file or added interactively
gems.each do |g|
  gem g
end

## Git
git :add => '-A' if prefer :git, true
git :commit => '-qm "rails_apps_composer: Gemfile"' if prefer :git, true

### CREATE DATABASE ###
after_bundler do
  copy_from_repo 'config/database-postgresql.yml', :prefs => 'postgresql'
  copy_from_repo 'config/database-mysql.yml', :prefs => 'mysql'
  default_username = ENV['USER']
  if prefer :database, 'postgresql'
    begin
      pg_username = ask_wizard("Username for PostgreSQL? (leave blank to use '#{default_username}')")
      if pg_username.blank?
        say_wizard "Creating a user named '#{default_username}' for PostgreSQL"
        run %{sudo su postgres -c "createuser -d -R -S #{default_username}"} if prefer :database, 'postgresql'
        gsub_file "config/database.yml", /username: .*/, "username: #{default_username}"
      else
        gsub_file "config/database.yml", /username: .*/, "username: #{pg_username}"
        pg_password = ask_wizard("Password for PostgreSQL user #{pg_username}?")
        gsub_file "config/database.yml", /password:/, "password: #{pg_password}"
        say_wizard "set config/database.yml for username/password #{pg_username}/#{pg_password}"
      end
    rescue StandardError => e
      raise "unable to create a user for PostgreSQL, reason: #{e}"
    end
    gsub_file "config/database.yml", /database: myapp_development/, "database: #{app_name}_development"
    gsub_file "config/database.yml", /database: myapp_test/,        "database: #{app_name}_test"
    gsub_file "config/database.yml", /database: myapp_production/,  "database: #{app_name}_production"
  end
  if prefer :database, 'mysql'
    mysql_username = ask_wizard("Username for MySQL? (leave blank to use '#{default_username}')")
    if mysql_username.blank?
      gsub_file "config/database.yml", /username: .*/, "username: #{default_username}"
    else
      gsub_file "config/database.yml", /username: .*/, "username: #{mysql_username}"
      mysql_password = ask_wizard("Password for MySQL user #{mysql_username}?")
      gsub_file "config/database.yml", /password:/, "password: #{mysql_password}"
      say_wizard "set config/database.yml for username/password #{mysql_username}/#{mysql_password}"
    end
    gsub_file "config/database.yml", /database: myapp_development/, "database: #{app_name}_development"
    gsub_file "config/database.yml", /database: myapp_test/,        "database: #{app_name}_test"
    gsub_file "config/database.yml", /database: myapp_production/,  "database: #{app_name}_production"
  end
  unless prefer :database, 'sqlite'
    affirm = yes_wizard? "Drop any existing databases named with prefix #{app_name}_?"
    if affirm
      run 'bundle exec rake db:drop'
    else
      raise "aborted at user's request"
    end
  end
  run 'bundle exec rake db:create:all'
  ## Git
  git :add => '-A' if prefer :git, true
  git :commit => '-qm "rails_apps_composer: create database"' if prefer :git, true
end # after_bundler

### GENERATORS ###
after_bundler do
  ## Front-end Framework
  generate 'foundation:install' if prefer :frontend, 'foundation'
  ## Git
  git :add => '-A' if prefer :git, true
  git :commit => '-qm "rails_apps_composer: generators"' if prefer :git, true
end # after_bundler

__END__

name: gems
description: "Add the gems your application needs."
author: RailsApps

requires: [setup]
run_after: [setup]
category: configuration
