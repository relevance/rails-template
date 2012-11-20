require 'rspec'

TEST_TMPDIR = File.expand_path("../tmp/", __FILE__)
SUPPORT_DIR = File.expand_path("../support", __FILE__)

TEST_APPDIR        = TEST_TMPDIR + "/app_dir"
TEST_TEMPLATE_FILE = TEST_TMPDIR + "/test_template.rb"
DEFAULT_FILE       = SUPPORT_DIR + '/defaults.yml'
TEST_DEFAULT_FILE  = TEST_TMPDIR + '/defaults.yml'

RSpec.configure do |config|
  config.mock_with :rspec
end


def do_defaults(&blk)
  # Accept a runtime hash containing recipe and/or prefs keys 
  # we'll overlay atop the data in DEFAULT_FILE.
  base = YAML.load_file(DEFAULT_FILE)
  settings = base.deep_merge(blk.call)

  File.open(TEST_DEFAULT_FILE, "w") do |f|
    YAML.dump(settings, f)
  end

end

def testing_recipe(recipes, &blk)
  do_defaults(&blk)
  
  %x(make test_clean)
  %x(make test_template.rb)
end
