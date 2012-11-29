require 'spec_helper'

test_generator do
  testing_recipe "exception_notification" do
    prefs :stack => 'heroku'
  end

  specify "Gemfile contains 'exceptional'" do
    file_contains 'Gemfile', 'exceptional'
  end

  specify "config initializer note points to 'getexceptional.com'" do
    file_contains 'config/initializers/exceptional.txt', 'getexceptional.com'
  end
end
