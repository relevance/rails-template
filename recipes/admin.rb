if config['active_admin']
  prefs[:admin] = 'active_admin'
end

gem 'activeadmin' if config['active_admin']

after_bundler do
  generate "active_admin:install" if config['active_admin']
end

after_everything do
  run 'bundle exec rake db:migrate'
end

__END__

name: admin
description: "Add an admin console to your application"
author: Relevance

category: components
requires: [gems]
run_after: [gems]

config:
  - active_admin:
      type: boolean
      prompt: "Do you want to install ActiveAdmin?"
