# Application template recipe for the rails_apps_composer. Change the recipe here:
# https://github.com/RailsApps/rails_apps_composer/blob/master/recipes/testing.rb

after_bundler do
  say_wizard "recipe running after 'bundle install'"
  ### TEST/UNIT ###
  if prefer :unit_test, 'test_unit'
    inject_into_file 'config/application.rb', :after => "Rails::Application\n" do <<-RUBY

    config.generators do |g|
      #{"g.test_framework :test_unit, fixture_replacement: :fabrication" if prefer :fixtures, 'fabrication'}
      #{"g.fixture_replacement :fabrication, dir: 'test/fabricators'" if prefer :fixtures, 'fabrication'}
    end

RUBY
    end
  end
  ### RSPEC ###
  if prefer :unit_test, 'rspec'
    say_wizard "recipe installing RSpec"
    generate 'rspec:install'
    copy_from_repo 'spec/spec_helper.rb', :repo => 'https://raw.github.com/RailsApps/rails3-devise-rspec-cucumber/master/'
    generate 'email_spec:steps'
    inject_into_file 'spec/spec_helper.rb', "require 'email_spec'\n", :after => "require 'rspec/rails'\n"
    inject_into_file 'spec/spec_helper.rb', :after => "RSpec.configure do |config|\n" do <<-RUBY
  config.include(EmailSpec::Helpers)
  config.include(EmailSpec::Matchers)
RUBY
    end
    run 'rm -rf test/' # Removing test folder (not needed for RSpec)
    inject_into_file 'config/application.rb', :after => "Rails::Application\n" do <<-RUBY

    # don't generate RSpec tests for views and helpers
    config.generators do |g|
      #{"g.test_framework :rspec" if prefer :fixtures, 'none'}
      #{"g.test_framework :rspec, fixture: true" unless prefer :fixtures, 'none'}
      #{"g.fixture_replacement :factory_girl" if prefer :fixtures, 'factory_girl'}
      #{"g.fixture_replacement :machinist" if prefer :fixtures, 'machinist'}
      #{"g.fixture_replacement :fabrication" if prefer :fixtures, 'fabrication'}
      g.view_specs false
      g.helper_specs false
    end

RUBY
    end
    ## RSPEC AND MONGOID
    if prefer :orm, 'mongoid'
      # remove ActiveRecord artifacts
      gsub_file 'spec/spec_helper.rb', /config.fixture_path/, '# config.fixture_path'
      gsub_file 'spec/spec_helper.rb', /config.use_transactional_fixtures/, '# config.use_transactional_fixtures'
      # remove either possible occurrence of "require rails/test_unit/railtie"
      gsub_file 'config/application.rb', /require 'rails\/test_unit\/railtie'/, '# require "rails/test_unit/railtie"'
      gsub_file 'config/application.rb', /require "rails\/test_unit\/railtie"/, '# require "rails/test_unit/railtie"'
      # configure RSpec to use matchers from the mongoid-rspec gem
      create_file 'spec/support/mongoid.rb' do
      <<-RUBY
RSpec.configure do |config|
  config.include Mongoid::Matchers
end
RUBY
      end
    end
    ## RSPEC AND DEVISE
    if prefer :devise, true
      # add Devise test helpers
      create_file 'spec/support/devise.rb' do
      <<-RUBY
RSpec.configure do |config|
  config.include Devise::TestHelpers, :type => :controller
end
RUBY
      end
    end
  end

  ### GIT ###
  git :add => '-A' if prefer :git, true
  git :commit => '-qm "rails_apps_composer: testing framework"' if prefer :git, true
end # after_bundler

after_everything do
  say_wizard "recipe running after everything"
  ### FABRICATION ###
  if prefer :fixtures, 'fabrication'
    say_wizard "replacing FactoryGirl fixtures with Fabrication"
    remove_file 'spec/factories/users.rb'
    remove_file 'spec/fabricators/user_fabricator.rb'
    create_file 'spec/fabricators/user_fabricator.rb' do
      <<-RUBY
Fabricator(:user) do
  name     'Test User'
  email    'example@example.com'
  password 'please'
  password_confirmation 'please'
  # required if the Devise Confirmable module is used
  # confirmed_at Time.now
end
RUBY
    end
    gsub_file 'features/step_definitions/user_steps.rb', /@user = FactoryGirl.create\(:user, email: @visitor\[:email\]\)/, '@user = Fabricate(:user, email: @visitor[:email])'
    gsub_file 'spec/controllers/users_controller_spec.rb', /@user = FactoryGirl.create\(:user\)/, '@user = Fabricate(:user)'
  end
end # after_everything

__END__

name: testing
description: "Add testing framework."
author: RailsApps

requires: [setup, gems]
run_after: [setup, gems, authentication]
category: testing
