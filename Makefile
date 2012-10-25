RECIPES=$(wildcard recipes/*.rb)
TEMPLATES=$(wildcard templates/*)

all: template.rb

clean:
	rm -rf tempapp template.rb

tempapp: clean template.rb 
	bundle exec rails new tempapp -m template.rb

template.rb: defaults.yml $(RECIPES) $(TEMPLATES)
	bundle exec rails_apps_composer template ./template.rb -L -l ./recipes -d ./defaults.yml -t ./templates
