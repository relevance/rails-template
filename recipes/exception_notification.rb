require 'forwardable'

class ExceptionNotification
  extend Forwardable
  def_delegators :@generator, :gem, :ask_wizard, :say_wizard, :create_file, :insert_into_file
  attr_reader :config, :generator

  def initialize(generator, config)
    @generator = generator
    @config = config
  end
  
  def config_switch
    case config['exception_notification']
    when 'coalmine'
      gem 'coalmine', '~> 0.5.3'
      config['api_key'] = ask_wizard "Please enter your Coalmine API key:"
    when 'airbrake'
      gem 'airbrake', '~> 3.1.6'
      config['api_key'] = ask_wizard "Please enter your Airbrake API key:"
      config['host'] = ask_wizard "Please enter the Airbrake hostname you wish to use: (or hit enter to use the default)"
    end
  end

  def handle_coalmine
    say_wizard "recipe installing coalmine"
    create_file "config/initializers/coalmine.rb" do
      write_initializer_coalmine
    end
  end

  def write_initializer_coalmine
    <<-EOF.gsub(/^ {6}/, '')
      Coalmine.configure do |config|
        config.signature = '#{config['api_key']}'
        config.logger = Rails.logger
      end
    EOF
  end

  def handle_airbrake
    say_wizard "recipe installing airbrake"
    create_file "config/initializers/airbrake.rb" do
      write_initializer_airbrake
    end
    if config['host'].present?
      insert_into_file "config/initializers/airbrake.rb", :before => "end" do
        write_host_initializer_airbrake
      end
    end
  end
    
  def write_initializer_airbrake
    <<-EOF.gsub(/^ {6}/, '')
      Airbrake.configure do |config|
        config.api_key = '#{config['api_key']}'
      end
      EOF
  end

  def write_host_initializer_airbrake
    <<-EOF.gsub(/^ {4}/, '')
      config.host    = '#{config['host']}'
      config.port    = '80'
      config.secure  = config.port == 443
    EOF
  end
end


unless self.to_s == "main"
  prefs[:exception_notification] = config['exception_notification']

  worker = ExceptionNotification.new(self, config)
  
  worker.config_switch

  after_bundler do
    if prefer :exception_notification, 'coalmine'
      worker.handle_coalmine
    elsif prefer :exception_notification, 'airbrake'
      worker.handle_airbrake
    end

    if prefer :git, true
      git :add => '-A'
      git :commit => '-qm "rails_apps_composer: exception notification"'
    end
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
