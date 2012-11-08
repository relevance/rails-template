# Application template recipe for the rails_apps_composer. Change the recipe here:
# https://github.com/RailsApps/rails_apps_composer/blob/master/recipes/extras.rb

## QUIET ASSETS
gem 'quiet_assets', '>= 1.0.1', :group => :development

## AFTER_EVERYTHING
after_everything do
  say_wizard "recipe removing unnecessary files and whitespace"
  %w{
    public/index.html
    app/assets/images/rails.png
  }.each { |file| remove_file file }
  # remove commented lines and multiple blank lines from Gemfile
  # thanks to https://github.com/perfectline/template-bucket/blob/master/cleanup.rb
  gsub_file 'Gemfile', /#.*\n/, "\n"
  gsub_file 'Gemfile', /\n^\s*\n/, "\n"
  # remove commented lines and multiple blank lines from config/routes.rb
  gsub_file 'config/routes.rb', /  #.*\n/, "\n"
  gsub_file 'config/routes.rb', /\n^\s*\n/, "\n"
  # GIT
  git :add => '-A' if prefer :git, true
  git :commit => '-qm "rails_apps_composer: extras"' if prefer :git, true
end

__END__

name: extras
description: "Various extras."
author: RailsApps

requires: [gems]
run_after: [gems, init, prelaunch]
category: other
