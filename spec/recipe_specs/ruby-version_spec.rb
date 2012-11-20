require 'spec_helper'

test_generator do
  testing_recipe "ruby_version" do
    {'prefs' => {
        :stack => 'heroku',
        :authentication => 'devise',
        :devise_modules => 'invitable',
        :devise_user => false,
        :omniauth_provider => 'facebook'}}
  end

  specify do
    destination_root.should have_structure do
      file '.ruby-version'
    end
  end
end
