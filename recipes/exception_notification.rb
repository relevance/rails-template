prefs[:exception_notification] = config['exception_notification']

case config['exception_notification']
when 'coalmine'
  gem 'coalmine', '~> 0.5.3'
  config['api_key'] = ask_wizard "Please enter your Coalmine API key:"
when 'airbrake'
  gem 'airbrake', '~> 3.1.6'
  config['api_key'] = ask_wizard "Please enter your Airbrake API key:"
  config['host'] = ask_wizard "Please enter the Airbrake hostname you wish to use: (or hit enter to use the default)"
end

def coalmine_initializer(api_key)
  <<-EOF.gsub(/^ {4}/, '')
    Coalmine.configure do |config|
      config.signature = '#{api_key}'
      config.logger = Rails.logger
    end
  EOF
end

def airbrake_initializer(api_key)
  <<-EOF.gsub(/^ {4}/, '')
    Airbrake.configure do |config|
      config.api_key = '#{api_key}'
    end
  EOF
end

def airbrake_host_initializer(host)
  <<-EOF.gsub(/^ {4}/, '')
      config.host    = '#{host}'
      config.port    = '80'
      config.secure  = config.port == 443
  EOF
end

after_bundler do
  if prefer :exception_notification, 'coalmine'
    say_wizard "recipe installing coalmine"
    create_file "config/initializers/coalmine.rb" do
      coalmine_initializer(config['api_key'])
    end
  elsif prefer :exception_notification, 'airbrake'
    say_wizard "recipe installing airbrake"
    create_file "config/initializers/airbrake.rb" do
      airbrake_initializer(config['api_key'])
    end
    if config['host'].present?
      insert_into_file "config/initializers/airbrake.rb", :before => "end" do
        airbrake_host_initializer(config['host'])
      end
    end
  end

  if prefer :git, true
    git :add => '-A'
    git :commit => '-qm "rails_apps_composer: exception notification"'
  end
end

__END__

name: exception_notification
description: "Install an exception notification system to gather exceptions."
author: Relevance

requires: [setup, gems]
run_after: [setup, gems]
category: configuration

config:
  - exception_notification:
      type: multiple_choice
      prompt: "What exception notification system would you like to use?"
      choices: [["None", "none"], ["Coalmine", "coalmine"], ["Airbrake", "airbrake"]]
