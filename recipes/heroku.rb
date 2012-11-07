if prefer :stack, "heroku"
  prefs[:database]       = "postgresql"
  prefs[:prod_webserver] = 'unicorn'
  prefs[:dev_webserver]  = 'unicorn'
  prefs[:unit_test]      = "rspec"
  prefs[:integration]    = "rspec-capybara"
  prefs[:fixtures]       = "factory_girl"
  prefs[:email]          = "gmail"
end

__END__

name: heroku
description: "Add blessed Heroku options."
author: RailsApps + Relevance

requires: [setup]
run_after: [setup]
category: configuration
