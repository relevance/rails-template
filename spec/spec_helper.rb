require 'rspec'
require 'thor'

TEST_TMPDIR = File.expand_path("../tmp/", __FILE__)

TEST_APPDIR        = TEST_TMPDIR + "/app_dir"
TEST_TEMPLATE_FILE = TEST_TMPDIR + "/test_template.rb"

RSpec.configure do |config|
    config.mock_with :rspec
end

def testing_recipe(recipes)
  %x(make clean test_template.rb DEFAULT_RECIPES=#{recipes})
end
