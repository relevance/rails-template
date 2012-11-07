require 'forwardable'

class RubyVersion
  extend Forwardable
  def_delegators :@generator, :say_wizard, :create_file, :create_link
  attr_reader :generator

  def initialize(generator, file, link)
    @generator = generator
    @file      = file
    @link      = link

    @version = "#{RUBY_VERSION}p#{RUBY_PATCHLEVEL}"
  end

  def announce
    say_wizard "recipe creating .ruby-version file and .rbenv-version symlink for Ruby #{@version}"
  end

  def make_file
    create_file @file do
      @version << "\n"
    end
  end

  def make_link
    create_link @link, @file
  end

end


rv = RubyVersion.new(self, ".ruby-version", ".rbenv-version")
rv.announce
rv.make_file
rv.make_link


git :add => '-A' if prefer :git, true
git :commit => '-qm "rails_apps_composer: .ruby-version and .rbenv-version"' if prefer :git, true

__END__

name: ruby-version
description: "Install a .ruby-version file and an .rbenv-version symlink to it."
author: RailsApps + Relevance

requires: [setup, gems]
run_after: [setup, gems]
category: configuration
