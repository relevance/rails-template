# Application template recipe for the rails_apps_composer. Change the recipe here:
# https://github.com/RailsApps/rails_apps_composer/blob/master/recipes/extras.rb

## QUIET ASSETS
gem 'quiet_assets', '>= 1.0.1', :group => :development

## JSRUNTIME
case RbConfig::CONFIG['host_os']
  when /linux/i
    prefs[:jsruntime] = yes_wizard? "Add 'therubyracer' JavaScript runtime (for Linux users without node.js)?" unless prefs.has_key? :jsruntime
    if prefs[:jsruntime]
      # was it already added for bootstrap-less?
      unless prefer :bootstrap, 'less'
        say_wizard "recipe adding 'therubyracer' JavaScript runtime gem"
        gem 'therubyracer', '>= 0.10.2', :group => :assets, :platform => :ruby
      end
    end
end

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

## GITHUB
if config['github']
  prefs[:github] = true
end
if prefs[:github]
  gem 'hub', '>= 1.10.2', :require => nil, :group => [:development]
  after_everything do
    say_wizard "recipe creating GitHub repository"
    git_uri = `git config remote.origin.url`.strip
    if git_uri.size > 0
      say_wizard "Repository already exists:"
      say_wizard "#{git_uri}"
    else
      run "hub create #{app_name}"
      run "hub push -u origin master"
    end
  end
end

__END__

name: extras
description: "Various extras."
author: RailsApps

requires: [gems]
run_after: [gems, init, prelaunch]
category: other

config:
  - rvmrc:
      type: boolean
      prompt: Create a project-specific rvm gemset and .rvmrc?
