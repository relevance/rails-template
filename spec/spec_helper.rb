require 'rspec'
require 'active_model'
require 'action_view'
require 'action_controller'

require 'rails/generators'
require 'rails/generators/rails/app/app_generator'
require 'generator_spec/test_case'
require 'support/matchers'
require 'capybara/rspec'
require 'capybara-webkit'
require 'headless'

TEST_APP_NAME = "DIE"

TEST_TMPDIR = File.expand_path("../tmp/", __FILE__)
SUPPORT_DIR = File.expand_path("../support", __FILE__)

TEST_APP_CONTAINER = TEST_TMPDIR + "/app_dir"
TEST_TEMPLATE_FILE = TEST_TMPDIR + "/test_template.rb"
DEFAULT_FILE       = SUPPORT_DIR + "/defaults.yml"
TEST_DEFAULT_FILE  = TEST_TMPDIR + "/defaults.yml"

TEST_APP_DIR       = TEST_APP_CONTAINER + "/" + TEST_APP_NAME

RSpec.configure do |config|
  config.mock_with :rspec
  config.include Capybara::DSL
  Capybara.javascript_driver = :webkit
  Capybara.default_driver = :webkit
end

def test_generator(&blk)
  describe Rails::Generators::AppGenerator, :type => :request do
    include GeneratorSpec::TestCase
    destination TEST_APP_CONTAINER
    arguments [TEST_APP_NAME, "-m", TEST_TEMPLATE_FILE]

    instance_eval(&blk)

    # run_generator leaves us in the TEST_APP_CONTAINER dir.
    after(:all) do
      Dir.chdir("../../../..")
      FileUtils.rmdir(TEST_APP_DIR)
    end

    before(:all) do
      Headless.new(:destroy_on_exit => true).start
      prepare_destination
      run_generator
    end
  end
end

class TestGeneratorConfig
  def self.build(&block)
    config = new
    config.instance_eval(&block)
    config
  end

  def prefs(preferences={})
    @prefs ||= {'prefs' => ({}.merge(preferences))}
  end
end

def do_defaults(&blk)
  # Accept a runtime hash containing recipe and/or prefs keys
  # we'll overlay atop the data in DEFAULT_FILE.
  base = YAML.load_file(DEFAULT_FILE)
  settings = base.deep_merge(TestGeneratorConfig.build(&blk).prefs)

  File.open(TEST_DEFAULT_FILE, "w") do |f|
    YAML.dump(settings, f)
  end
end

def testing_recipe(recipes, &blk)
  before(:all) do
    do_defaults(&blk)

    %x(make drop_app_dbs)
    %x(make remove_test_app_container)
    %x(make test_template.rb)
  end
end

def app_root(path)
  TEST_APP_NAME + "/" + path
end

def file_contains(file, *text)
  destination_root.should have_structure {
    file(app_root(file)) do
    text.each { |t| contains t }
    end
  }
end

def file_omits(file, *text)
  destination_root.should have_structure {
    file(app_root(file)) do
    text.each { |t| omits t }
    end
  }
end

def migration_contains(file, *text)
  destination_root.should have_structure {
    directory(app_root("db")) do
    directory "migrate" do
      migration file do
        text.each {|t| contains t }
      end
    end
    end
  }
end
