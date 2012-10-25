## Form Builder
prefs[:form_builder] = config['form_builder']

case config['form_builder']
when 'simple_form'
  gem 'simple_form', '~> 2.0.4'
when 'formtastic'
  gem 'formtastic'
end

after_bundler do
  ## Form Builder
  if prefer :form_builder, 'simple_form'
    say_wizard "recipe installing simple_form"
    generate 'simple_form:install'
  elsif prefer :form_builder, 'formtastic'
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
run_after: [setup, gems]
category: frontend

config:
  - form_builder:
      type: multiple_choice
      prompt: "What form builder would you like to use?"
      choices: [["None", "none"], ["SimpleForm", "simple_form"], ["Formtastic", "formtastic"]]
