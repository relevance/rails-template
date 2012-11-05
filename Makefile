RECIPES=$(wildcard recipes/*.rb)
TEMPLATES=$(wildcard templates/*)
TEST_TEMPLATES=$(wildcard spec/support/templates/*)

all: template.rb

clean:
	rm -rf tempapp template.rb test_template.rb

tempapp: clean template.rb 
	rails new tempapp -m template.rb

template.rb: defaults.yml $(RECIPES) $(TEMPLATES)
	bundle exec rails_apps_composer template ./template.rb -L -l ./recipes -d ./defaults.yml -t ./templates

test_template.rb: defaults.yml $(RECIPES) $(TEST_TEMPLATES)
	bundle exec rails_apps_composer template ./spec/tmp/test_template.rb -L -l ./recipes -d ./spec/support/defaults.yml -t ./spec/support/templates -r $(DEFAULT_RECIPES) -q

