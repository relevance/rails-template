prefs[:authentication] = config['authentication']
prefs[:devise] = !!config['authentication'].match(/devise/)
prefs[:omniauth] = !!config['authentication'].match(/omniauth/)

if prefs[:devise]
  prefs[:devise_modules] = multiple_choice("Devise modules?", [
                                             ["Devise with default modules", "default"],
                                             ["Devise with Confirmable module", "confirmable"],
                                             ["Devise with Confirmable and Invitable modules", "invitable"]])

  gem 'devise', '~> 2.1.2'
  gem 'devise_invitable', '~> 1.0.3' if prefer :devise_modules, 'invitable'

  prefs[:devise_user] = yes_wizard?("Do you want to create a User model for Devise?")
end

if prefs[:omniauth]
  prefs[:omniauth_provider] = multiple_choice("OmniAuth provider?", [
                                                ["Facebook", "facebook"],
                                                ["Twitter", "twitter"],
                                                ["GitHub", "github"],
                                                ["LinkedIn", "linkedin"],
                                                ["Google-Oauth-2", "google_oauth2"],
                                                ["Tumblr", "tumblr"]])

  gem 'omniauth', '~> 1.1.1'
  gem 'omniauth-twitter' if prefer :omniauth_provider, 'twitter'
  gem 'omniauth-facebook' if prefer :omniauth_provider, 'facebook'
  gem 'omniauth-github' if prefer :omniauth_provider, 'github'
  gem 'omniauth-linkedin' if prefer :omniauth_provider, 'linkedin'
  gem 'omniauth-google-oauth2' if prefer :omniauth_provider, 'google_oauth2'
  gem 'omniauth-tumblr' if prefer :omniauth_provider, 'tumblr'
end

after_bundler do
  say_wizard "recipe running after 'bundle install'"
  ### DEVISE ###
  if prefs[:devise]
    # prevent logging of password_confirmation
    gsub_file 'config/application.rb', /:password/, ':password, :password_confirmation'
    generate 'devise:install'
    generate 'devise_invitable:install' if prefer :devise_modules, 'invitable'
    if prefs[:devise_user]
      generate 'devise user' # create the User model

      ## DEVISE AND ACTIVE RECORD
      generate 'migration AddNameToUsers name:string'
      copy_from_repo 'app/models/user.rb', :repo => 'https://raw.github.com/RailsApps/rails3-devise-rspec-cucumber/master/'
      if prefer(:devise_modules, 'confirmable') || prefer(:devise_modules, 'invitable')
        gsub_file 'app/models/user.rb', /:registerable,/, ":registerable, :confirmable,"
        generate 'migration AddConfirmableToUsers confirmation_token:string confirmed_at:datetime confirmation_sent_at:datetime unconfirmed_email:string'
      end
    end
  end

  ### OMNIAUTH ###
  if prefs[:omniauth]
    repo = 'https://raw.github.com/RailsApps/rails3-mongoid-omniauth/master/'
    copy_from_repo 'config/initializers/omniauth.rb', :repo => repo
    gsub_file 'config/initializers/omniauth.rb', /twitter/, prefs[:omniauth_provider] unless prefer :omniauth_provider, 'twitter'
  end

  ### OMNIAUTH ONLY ###
  if prefer :authentication, 'omniauth'
    generate 'model User name:string email:string provider:string uid:string'
    run 'bundle exec rake db:migrate'
    copy_from_repo 'app/models/user.rb', :repo => repo  # copy the User model (Mongoid version)
    gsub_file 'app/models/user.rb', /class User/, 'class User < ActiveRecord::Base'
    gsub_file 'app/models/user.rb', /^\s*include Mongoid::Document\n/, ''
    gsub_file 'app/models/user.rb', /^\s*field.*\n/, ''
    gsub_file 'app/models/user.rb', /^\s*# run 'rake db:mongoid:create_indexes' to create indexes\n/, ''
    gsub_file 'app/models/user.rb', /^\s*index\(\{ email: 1 \}, \{ unique: true, background: true \}\)\n/, ''
  end

  ### DEVISE + OMNIAUTH ###
  if prefer :authentication, 'devise-omniauth'
    if prefer :devise_user, true
      generate 'migration AddOmniauthColumnsToUsers provider:string uid:string'

      gsub_file 'app/models/user.rb', /^end$/, <<-FILE

  # See https://github.com/plataformatec/devise/wiki/OmniAuth:-Overview
  # for more details on using Devise + OmniAuth
  attr_accessible :provider, :uid
  devise :omniauthable

end
FILE
      insert_into_file('config/initializers/devise.rb',
                  "\n  config.omniauth :#{prefs[:omniauth_provider]}, 'APP_ID', 'APP_SECRET'",
                  :after => "Devise.setup do |config|")
    end
  end

  ### GIT ###
  git :add => '-A' if prefer :git, true
  git :commit => '-qm "rails_apps_composer: authentication"' if prefer :git, true
end

after_everything do
  if prefer(:authentication, 'devise') && prefer(:devise_user, true)
    if prefer(:devise_modules, 'confirmable') || prefer(:devise_modules, 'invitable')
      ## DEVISE-CONFIRMABLE
      append_file 'db/seeds.rb' do <<-FILE
puts 'SETTING UP DEFAULT USER LOGIN'
user = User.create! :name => 'First User', :email => 'user@example.com', :password => 'please', :password_confirmation => 'please'
user.confirm!
puts 'New user created: ' << user.name
user2 = User.create! :name => 'Second User', :email => 'user2@example.com', :password => 'please', :password_confirmation => 'please'
user2.confirm!
puts 'New user created: ' << user2.name
FILE
      end
    else
      ## DEVISE-DEFAULT
      append_file 'db/seeds.rb' do <<-FILE
puts 'SETTING UP DEFAULT USER LOGIN'
user = User.create! :name => 'First User', :email => 'user@example.com', :password => 'please', :password_confirmation => 'please'
puts 'New user created: ' << user.name
user2 = User.create! :name => 'Second User', :email => 'user2@example.com', :password => 'please', :password_confirmation => 'please'
puts 'New user created: ' << user2.name
FILE
      end
    end
    ## DEVISE-INVITABLE
    if prefer :devise_modules, 'invitable'
      run 'bundle exec rake db:migrate'
      generate 'devise_invitable user'
    end
  end
end

__END__

name: authentication
description: "Choose an authentication solution."
author: Relevance

requires: [setup, git]
run_after: [setup, git]
category: components

config:
  - authentication:
      type: multiple_choice
      prompt: "What authentication solution would you like to use?"
      choices: [["None", "none"], ["Devise", "devise"], ["OmniAuth", "omniauth"], ["Devise + OmniAuth", "devise-omniauth"]]
