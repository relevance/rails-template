RECIPES=$(wildcard recipes/*.rb)

all: template.rb

clean:
	rm -rf tempapp template.rb

tempapp: clean template.rb 
	rails new tempapp -m template.rb

template.rb: defaults.yml $(RECIPES)
	rails_apps_composer template ./template.rb -l ./recipes -d ./defaults.yml -t ./templates
