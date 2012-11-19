# Application template recipe for the rails_apps_composer. Change the recipe here:
# https://github.com/RailsApps/rails_apps_composer/blob/master/recipes/setup.rb

## Ruby on Rails
HOST_OS = RbConfig::CONFIG['host_os']
say_wizard "Your operating system is #{HOST_OS}."
say_wizard "You are using Ruby version #{RUBY_VERSION}."
say_wizard "You are using Rails version #{Rails::VERSION::STRING}."


prefs[:stack] = multiple_choice "Choose your stack", [["Heroku", "heroku"], ["EC2", "ec2"]] unless prefs.has_key? :stack

prefs[:admin] = yes_wizard? "Do you want to install ActiveAdmin?" unless prefs.has_key? :admin

prefs[:authentication] = multiple_choice "What authentication solution would you like to use?",
[["None", "none"], ["Devise", "devise"], ["OmniAuth", "omniauth"], ["Devise + OmniAuth", "devise-omniauth"]] unless prefs.has_key? :authentication


# save diagnostics before anything can fail
create_file "README", "RECIPES\n#{recipes.sort.inspect}\n"
append_file "README", "PREFERENCES\n#{prefs.inspect}"

__END__

name: setup
description: "Make choices for your application."
author: RailsApps

run_after: [git]
category: configuration
