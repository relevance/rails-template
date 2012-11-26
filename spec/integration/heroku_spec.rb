require 'spec_helper'

test_generator do
  include Capybara::DSL
  testing_recipe "heroku stack" do
    { prefs: { stack: 'heroku',
               authentication: 'devise',
               devise_user: true,
               devise_modules: 'default' } }
  end

  before(:all) do
    # find the name of the heroku app (/config/heroku.yml?)
    # go to generated app
    # add the heroku remote (git remote ...)
    # git push heroku remote (deploy)
    Capybara.app_host = 'http://rails-template-test.herokuapp.com'
  end

  it 'does it' do
    visit "/"
    puts page.body
  end
end
