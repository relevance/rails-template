RECIPES=$(wildcard recipes/*.rb)
TEMPLATES=$(wildcard templates/*)
TEST_TEMPLATES=$(wildcard spec/support/templates/*)

all: template.rb

clean:
	cd DIE; rake db:drop:all; cd ..
	rm -rf DIE template.rb test_template.rb

tempapp: clean template.rb 
	rails new tempapp -m template.rb

template.rb: defaults.yml $(RECIPES) $(TEMPLATES)
	bundle exec rails_apps_composer template ./template.rb -L -l ./recipes -d ./defaults.yml -t ./templates

test_template.rb: $(RECIPES) $(TEST_TEMPLATES)
	bundle exec rails_apps_composer template ./spec/tmp/test_template.rb -L -l ./recipes -t ./spec/support/templates -r $(DEFAULT_RECIPES) -q

