# Application template recipe for the rails_apps_composer. Change the recipe here:
# https://github.com/RailsApps/rails_apps_composer/blob/master/recipes/controllers.rb

after_bundler do
  say_wizard "recipe running after 'bundle install'"
  ### APPLICATION_CONTROLLER ###
  if prefer :authentication, 'omniauth'
    copy_from_repo 'app/controllers/application_controller.rb', :repo => 'https://raw.github.com/RailsApps/rails3-mongoid-omniauth/master/'
  end

  ### SESSIONS_CONTROLLER ###
  if prefer :authentication, 'omniauth'
    filename = 'app/controllers/sessions_controller.rb'
    copy_from_repo filename, :repo => 'https://raw.github.com/RailsApps/rails3-mongoid-omniauth/master/'
    gsub_file filename, /twitter/, prefs[:omniauth_provider] unless prefer :omniauth_provider, 'twitter'
  end
  ### GIT ###
  git :add => '-A' if prefer :git, true
  git :commit => '-qm "rails_apps_composer: controllers"' if prefer :git, true
end # after_bundler

__END__

name: controllers
description: "Add controllers needed for starter apps."
author: RailsApps

requires: [setup, gems, models]
run_after: [setup, gems, models]
category: mvc
