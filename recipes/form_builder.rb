if prefer :form_builder, 'formtastic'
  gem 'formtastic'
end

after_bundler do
  if prefer :form_builder, 'formtastic'
    say_wizard "recipe installing formtastic"
    generate 'formtastic:install'
  end

  if prefer :git, true
    git :add => '-A'
    git :commit => '-qm "rails_apps_composer: form builders"'
  end
end

__END__

name: form_builder
description: "Install a form builder to create HTML forms."
author: Relevance

requires: [setup, gems]
run_after: [setup, gems, admin]
category: frontend
