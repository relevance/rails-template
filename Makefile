RECIPES=$(wildcard recipes/*.rb)

all: template.rb

clean:
	rm -rf tempapp

tempapp: template.rb clean
	rails new tempapp -m template.rb

template.rb: defaults.yml $(RECIPES)
	rails_apps_composer template ./template.rb -l ./recipes -d ./defaults.yml
