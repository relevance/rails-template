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

  ### HOME_CONTROLLER
  if prefer(:authentication, 'devise') && prefer(:devise_user, true)
    generate 'controller home index' 
    insert_into_file 'app/controllers/home_controller.rb', "\n  before_filter :authenticate_user!\n", :before => "def index"
    insert_into_file 'app/controllers/home_controller.rb', "\n    @users = User.all", :after => "def index"
    copy_from_repo 'app/views/home/index.html.erb'
  end

  ### USERS_CONTROLLER
  if prefer(:authentication, 'devise') && prefer(:devise_user, true)
    generate 'controller users show'
    copy_from_repo 'app/views/users/show.html.erb'
    insert_into_file 'app/controllers/users_controller.rb', "\n  @user = User.find(params[:id])", :after => 'def show'
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
