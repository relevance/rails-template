# Application template recipe for the rails_apps_composer. Change the recipe here:
# https://github.com/RailsApps/rails_apps_composer/blob/master/recipes/readme.rb

after_everything do
  say_wizard "recipe running after everything"

  # remove default READMEs
  %w{
    README
    README.rdoc
    doc/README_FOR_APP
  }.each { |file| remove_file file }

  # add placeholder READMEs and humans.txt file
  copy_from_repo 'public/humans.txt'
  copy_from_repo 'README'
  copy_from_repo 'README.textile'
  gsub_file "README", /App_Name/, "#{app_name.humanize.titleize}"
  gsub_file "README.textile", /App_Name/, "#{app_name.humanize.titleize}"

  # Diagnostics
  gsub_file "README.textile", /recipes that are known/, "recipes that are NOT known" if diagnostics[:recipes] == 'fail'
  gsub_file "README.textile", /preferences that are known/, "preferences that are NOT known" if diagnostics[:prefs] == 'fail'
  gsub_file "README.textile", /RECIPES/, recipes.sort.inspect
  gsub_file "README.textile", /PREFERENCES/, prefs.inspect
  gsub_file "README", /RECIPES/, recipes.sort.inspect
  gsub_file "README", /PREFERENCES/, prefs.inspect

  # Ruby on Rails
  gsub_file "README.textile", /\* Ruby/, "* Ruby version #{RUBY_VERSION}"
  gsub_file "README.textile", /\* Rails/, "* Rails version #{Rails::VERSION::STRING}"
end # after_everything

__END__

name: readme
description: "Build a README file for your application."
author: RailsApps

requires: [setup]
run_after: [setup]
category: configuration
