require 'spec_helper'

test_generator do
  testing_recipe "exception_notification" do
    {'prefs' => {:stack => 'heroku'}}
  end

  specify "Gemfile contains 'exceptional'" do
    destination_root.should have_structure {
      file 'DIE/Gemfile' do
        contains 'exceptional'
      end
    }
  end

  specify "config initializer note points to 'getexceptional.com'" do
    destination_root.should have_structure {
      file 'DIE/config/initializers/exceptional.txt' do
        contains 'getexceptional.com'
      end
    }
  end
end
