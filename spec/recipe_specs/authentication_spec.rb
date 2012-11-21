require 'spec_helper'


# * authentication grid
# | mod      | default | confirmable | invitable | noproviders | all providers |
# | devise   | x       |             | x         |             |               |
# | both     | x       | x           | x         |             |               |
# | omniauth |         |             |           |     x       |        x      |

test_generator do
  testing_recipe "authentication" do
    {'prefs' => {:stack => 'heroku', :authentication => 'devise', :devise_user => true, :devise_modules => 'invitable' }}
  end

  specify do
    file_has_content "Gemfile", "devise_invitable"
    file_has_content "config/initializers/devise.rb", "Devise.setup", "config.invite_for"
    migration_exists "devise_invitable_add_to_users"
  end
end
