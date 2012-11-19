
if prefs[:admin]
  prefs['form_builder'] = 'formtastic'

  gem 'activeadmin'

  after_bundler do
    generate "active_admin:install"
  end
end

__END__

name: admin
description: "Add an admin console to your application"
author: Relevance

category: components
requires: [setup, gems]
run_after: [gems]
