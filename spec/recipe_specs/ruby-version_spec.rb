require 'spec_helper'
require 'active_model'
require 'action_view'
require 'action_controller'

require 'rails/generators'
require 'rails/generators/rails/app/app_generator'
require 'generator_spec/test_case'

describe Rails::Generators::AppGenerator do
  include GeneratorSpec::TestCase
  destination TEST_APPDIR
  arguments ["DIE", "-m", TEST_TEMPLATE_FILE]

  before do
    testing_recipe "ruby_version"
    prepare_destination
    run_generator
  end

  it 'creates a ruby version file' do
    File.exists?('.ruby-version').should be true
  end

end
