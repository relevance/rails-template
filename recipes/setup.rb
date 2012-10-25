# Application template recipe for the rails_apps_composer. Change the recipe here:
# https://github.com/RailsApps/rails_apps_composer/blob/master/recipes/setup.rb

## Ruby on Rails
HOST_OS = RbConfig::CONFIG['host_os']
say_wizard "Your operating system is #{HOST_OS}."
say_wizard "You are using Ruby version #{RUBY_VERSION}."
say_wizard "You are using Rails version #{Rails::VERSION::STRING}."

## Is sqlite3 in the Gemfile?
gemfile = File.read(destination_root() + '/Gemfile')
sqlite_detected = gemfile.include? 'sqlite3'

prefs[:heroku] = yes_wizard? "Are you deploying to Heroku?"

## Web Server
webservers = {"Thin" => "thin", "Unicorn" => "unicorn", "Puma" => "puma"}
unless prefs[:heroku]
  webservers["Passenger"] = "passenger"
end

prefs[:dev_webserver] = multiple_choice "Web server for development?", [["WEBrick (default)", "webrick"],
  ["Thin", "thin"], ["Unicorn", "unicorn"], ["Puma", "puma"]] unless prefs.has_key? :dev_webserver
webserver = multiple_choice "Web server for production?", webservers.to_a unless prefs.has_key? :prod_webserver
if webserver == 'same'
  case prefs[:dev_webserver]
    when 'thin'
      prefs[:prod_webserver] = 'thin'
    when 'unicorn'
      prefs[:prod_webserver] = 'unicorn'
    when 'puma'
      prefs[:prod_webserver] = 'puma'
  end
else
  prefs[:prod_webserver] = webserver
end

## Database Adapter
prefs[:database] = multiple_choice "Database used for application?", [["PostgreSQL", "postgresql"], ["MySQL", "mysql"]] unless prefs.has_key? :database

## Template Engine
prefs[:templates] = multiple_choice "Template engine?", [["ERB", "erb"], ["Haml", "haml"], ["Slim (experimental)", "slim"]] unless prefs.has_key? :templates

## Testing Framework
if recipes.include? 'testing'
  prefs[:unit_test] = multiple_choice "Unit testing?", [["Test::Unit", "test_unit"], ["RSpec", "rspec"], ["MiniTest", "minitest"]] unless prefs.has_key? :unit_test
  prefs[:integration] = multiple_choice "Integration testing?", [["None", "none"], ["RSpec with Capybara", "rspec-capybara"],
    ["Cucumber with Capybara", "cucumber"], ["Turnip with Capybara", "turnip"], ["MiniTest with Capybara", "minitest-capybara"]] unless prefs.has_key? :integration
  prefs[:fixtures] = multiple_choice "Fixture replacement?", [["None","none"], ["Factory Girl","factory_girl"], ["Machinist","machinist"], ["Fabrication","fabrication"]] unless prefs.has_key? :fixtures
end

## Email
if recipes.include? 'email'
  prefs[:email] = multiple_choice "Add support for sending email?", [["None", "none"], ["Gmail","gmail"], ["SMTP","smtp"],
    ["SendGrid","sendgrid"], ["Mandrill","mandrill"]] unless prefs.has_key? :email
else
  prefs[:email] = 'none'
end

## Authentication and Authorization
if recipes.include? 'models'
  prefs[:authentication] = multiple_choice "Authentication?", [["None", "none"], ["Devise", "devise"], ["OmniAuth", "omniauth"]] unless prefs.has_key? :authentication
  case prefs[:authentication]
    when 'devise'
      if prefer :orm, 'mongoid'
        prefs[:devise_modules] = multiple_choice "Devise modules?", [["Devise with default modules","default"]] unless prefs.has_key? :devise_modules
      else
        prefs[:devise_modules] = multiple_choice "Devise modules?", [["Devise with default modules","default"], ["Devise with Confirmable module","confirmable"],
          ["Devise with Confirmable and Invitable modules","invitable"]] unless prefs.has_key? :devise_modules
      end
    when 'omniauth'
      prefs[:omniauth_provider] = multiple_choice "OmniAuth provider?", [["Facebook", "facebook"], ["Twitter", "twitter"], ["GitHub", "github"],
        ["LinkedIn", "linkedin"], ["Google-Oauth-2", "google_oauth2"], ["Tumblr", "tumblr"]] unless prefs.has_key? :omniauth_provider
  end
end

# save diagnostics before anything can fail
create_file "README", "RECIPES\n#{recipes.sort.inspect}\n"
append_file "README", "PREFERENCES\n#{prefs.inspect}"

__END__

name: setup
description: "Make choices for your application."
author: RailsApps

run_after: [git]
category: configuration
