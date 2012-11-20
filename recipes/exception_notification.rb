say_wizard "recipe installing exceptional"
gem 'exceptional'

after_bundler do
  # create_file "config/initializers/coalmine.rb" do
  #   write_initializer_coalmine
  # end

  if prefer :git, true
    git :add => '-A'
    git :commit => '-qm "rails_apps_composer: exceptional"'
  end
end

__END__


name: exception_notification
description: "Install an exception notification system to gather exceptions."
author: Relevance

requires: [setup, gems]
run_after: [setup, gems]
category: configuration
