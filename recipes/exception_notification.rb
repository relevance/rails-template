say_wizard "recipe installing exceptional"
gem 'exceptional'
create_file "config/initializers/exceptional.txt", "Further instructions for Exceptional setup are available at http://getexceptional.com/"

__END__


name: exception_notification
description: "Install an exception notification system to gather exceptions."
author: Relevance

requires: [setup, gems]
run_after: [setup, gems]
category: configuration
