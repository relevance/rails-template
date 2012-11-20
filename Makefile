RECIPES=$(wildcard recipes/*.rb)
TEMPLATES=$(wildcard templates/*)
TEST_TEMPLATES=$(wildcard spec/support/templates/*)

all: template.rb

clean:
	cd DIE; rake db:drop:all; cd ..
	rm -rf DIE template.rb

test_clean:
	dropdb DIE_production; dropdb DIE_development; dropdb DIE_test;
	rm -rf spec/tmp/app_dir/DIE ./spec/tmp/test_template.rb

tempapp: clean template.rb 
	rails new tempapp -m template.rb

template.rb: defaults.yml $(RECIPES) $(TEMPLATES)
	bundle exec rails_apps_composer template ./template.rb -L -l ./recipes -d ./defaults.yml -t ./templates

test_template.rb: $(RECIPES) $(TEST_TEMPLATES)
	bundle exec rails_apps_composer template ./spec/tmp/test_template.rb -L -l ./recipes -d ./spec/tmp/defaults.yml -t ./spec/support/templates -q

