# Guessing at these settings; making them all-different from Heroku means we can move forward with testing.

if prefer :stack, "ec2"
  prefs[:database]       = "mysql"
  prefs[:dev_webserver]  = "thin"
  prefs[:prod_webserver] = "thin"
  prefs[:templates]      = "slim"
  prefs[:unit_test]      = "minitest" # TODO: Conditionally undo skip_test_unit arg in defaults.yml
  prefs[:integration]    = "minitest-capybara"
  prefs[:fixtures]       = "machinist"
  prefs[:email]          = "smtp"
end

__END__

name: ec2
description: "Add blessed EC2 options."
author: RailsApps + Relevance

requires: [setup]
run_after: [setup]
category: configuration
