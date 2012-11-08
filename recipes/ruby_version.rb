RUBY_VERSION_PATCH = "#{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}"

say_wizard "recipe creating .ruby-version file and .rbenv-version symlink for Ruby #{RUBY_VERSION_PATCH}"
create_file('.ruby-version') { RUBY_VERSION_PATCH << "\n" }
create_link '.rbenv-version', '.ruby-version'

git :add => '-A' if prefer :git, true
git :commit => '-qm "rails_apps_composer: .ruby-version and .rbenv-version"' if prefer :git, true

__END__

name: ruby-version
description: "Install a .ruby-version file and an .rbenv-version symlink to it."
author: RailsApps + Relevance

requires: [setup, gems]
run_after: [setup, gems]
category: configuration
