require 'spec_helper'

# * TODO Selection combos currently deemed worth covering.
# |          | (d) default | (d) conf. | (d) inv. | (oa) twitter | (oa) all |
# | devise   | x           | x         | x        |              |          |
# | omniauth |             |           |          | x            | ?        |
# | both     | _           | _         | _        |              | ?        | 

#  [x] Done.
#  [_] TODO
#  [?] Requires multiple-select branch to be merged.

test_generator do
  testing_recipe "devise with default modules" do
    {'prefs' => {:stack => 'heroku', :authentication => 'devise', :devise_user => true, :devise_modules => 'default' }}
  end
  specify do
    file_contains "Gemfile", "devise"
    file_contains "config/initializers/devise.rb", "Devise.setup"
    migration_contains "devise_create_users", "class"
  end
end

test_generator do
  testing_recipe "devise with confirmable module" do
    {'prefs' => {:stack => 'heroku', :authentication => 'devise', :devise_user => true, :devise_modules => 'confirmable' }}
  end
  specify do
    file_contains "db/seeds.rb", "user.confirm!"
  end
end

test_generator do
  testing_recipe "devise with invitable module" do
    {'prefs' => {:stack => 'heroku', :authentication => 'devise', :devise_user => true, :devise_modules => 'invitable' }}
  end
  specify do
    file_contains "Gemfile", "devise_invitable"
    file_contains "config/initializers/devise.rb", "config.invite_for"
    migration_contains "devise_invitable_add_to_users", "class"
  end
end

test_generator do
  testing_recipe "omniauth with no providers" do
    {'prefs' => {:stack => 'heroku', :authentication => 'omniauth', :omniauth_provider => "twitter" }}
  end
  specify do
    file_contains "Gemfile", "omniauth-twitter"
    file_contains "config/initializers/omniauth.rb", "twitter"
    migration_contains "create_user", ":provider"
  end
end
