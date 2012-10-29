# Application template recipe for the rails_apps_composer. Change the recipe here:
# https://github.com/RailsApps/rails_apps_composer/blob/master/recipes/frontend.rb

## Front-end Framework

prefs[:frontend] = config['frontend']

case config['frontend']
when 'compass'
  gem 'compass-rails', '~> 1.0.3', :group => :assets
when 'foundation'
  gem 'compass-rails', '~> 1.0.3', :group => :assets
  gem 'zurb-foundation', '~> 3.1.1', :group => :assets
end

after_bundler do
  say_wizard "recipe running after 'bundle install'"

  ### CSS ###
  if prefer :frontend, 'compass'
    run 'bundle exec compass init'
  elsif prefer :frontend, 'foundation'
    generator 'foundation:install'
    generator 'foundation:layout'
  end
  ### GIT ###
  git :add => '-A' if prefer :git, true
  git :commit => '-qm "rails_apps_composer: front-end framework"' if prefer :git, true
end # after_bundler

__END__

name: frontend
description: "Install a front-end framework for HTML5 and CSS."
author: RailsApps + Relevance

requires: [setup, gems]
run_after: [setup, gems]
category: frontend

config:
  - frontend:
      type: multiple_choice
      prompt: "What front-end framework would you like to use?"
      choices: [["None", "none"], ["Compass", "compass"], ["Compass + Zurb Foundation", "foundation"]]
