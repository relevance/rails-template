require 'spec_helper'

HEROKU_APP_NAME = 'relevance-rails-test'

test_generator do
  testing_recipe "heroku stack" do
    prefs stack: 'heroku',
          heroku_deploy: true,
          authentication: 'devise',
          devise_user: true,
          devise_modules: 'confirmable',
          heroku_app_name: HEROKU_APP_NAME
  end

  before(:all) do
    %x{heroku apps:destroy #{HEROKU_APP_NAME} --confirm #{HEROKU_APP_NAME}}
    Capybara.app_host = "http://#{HEROKU_APP_NAME}.herokuapp.com"
  end

  it 'logs in' do
    visit "/"
    page.should have_content "Sign in"
    fill_in "user_email", :with => 'user@example.com'
    fill_in "user_password", :with => 'password'
    click_on "Sign in"
  end
end
