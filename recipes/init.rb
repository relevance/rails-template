# Application template recipe for the rails_apps_composer. Change the recipe here:
# https://github.com/RailsApps/rails_apps_composer/blob/master/recipes/init.rb

after_everything do
  say_wizard "applying migrations and seeding the database"
  run 'bundle exec rake db:migrate'
  run 'bundle exec rake db:test:prepare'
  run 'bundle exec rake db:seed'
  ### GIT ###
  git :add => '-A' if prefer :git, true
  git :commit => '-qm "rails_apps_composer: set up database"' if prefer :git, true
end

__END__

name: init
description: "Set up and initialize database."
author: RailsApps + Relevance

requires: [setup, gems, models]
run_after: [setup, gems, models, authentication]
category: initialize
