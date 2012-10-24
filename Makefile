RECIPES=$(wildcard recipes/*.rb)

all: template.rb

template.rb: defaults.yml $(RECIPES)
	rails_apps_composer template ./template.rb -l ./recipes -d ./defaults.yml
