if prefer :admin, "true"
  prefs[:form_builder] = 'formtastic'

  gem 'activeadmin'

  after_bundler do
    generate "active_admin:install"

    ### GIT ###
    git :add => '-A' if prefer :git, true
    git :commit => '-qm "rails_apps_composer: active_admin"' if prefer :git, true
  end
end

__END__

name: admin
description: "Add an admin console to your application"
author: Relevance

category: components
requires: [setup, gems]
run_after: [gems]
