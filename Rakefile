
desc "Clean up our previous mess."
task :clean do
  sh "rm template.rb" if File.exist?("template.rb")
  sh "rm -rf ./spec/tmp/app_dir/DIE ./spec/tmp/test_template.rb"
  if File.exist?("DIE")
    sh "cd DIE; rake db:drop:all; cd .."
    sh "rm -rf DIE"
  end
end

namespace :compose do

  desc "Create an app. (was tempapp)"
  task :app, [:app_name] => [:create_template] do |t,args|
    fail "usage: rake compose:new[<app-name>]" if args.app_name.empty?
    sh "rm -rf #{args.app_name}"
	  sh "rails new #{args.app_name} -m template.rb"
  end

  desc "Build template.rb"
  task :create_template => [:clean] do
    fail "defaults.yml not found"  unless File.exist?("defaults.yml")
    fail "no recipes"              if Dir.glob("recipes/*.rb").empty?
    fail "no templates found" if Dir.glob("templates/*").empty?
	  sh "bundle exec rails_apps_composer template ./template.rb -L -l ./recipes -d ./defaults.yml -t ./templates"
  end

  desc "Create a test template"
  task :create_tests do
    fail "no test templates found" if Dir.glob("spec/support/templates/*").empty?
	  sh "bundle exec rails_apps_composer template ./spec/tmp/test_template.rb -L -l ./recipes -d ./spec/tmp/defaults.yml -t ./spec/support/templates -q"
  end

  desc "Drop databases"
  task :drop_dbs do
	  sh "dropdb DIE_production; dropdb DIE_development; dropdb DIE_test;"
  end

  desc "Clean up test directory"
  task :clean_tests do
	  sh "rm -rf ./spec/tmp/app_dir/DIE ./spec/tmp/test_template.rb"
    sh "cd DIE; rake db:drop:all; cd .."
    sh "rm -rf DIE"
  end
end

desc "Instructions"
task :default do
  puts "usage: rake compose:app[<app-name>]"
  puts "run `rake -T` for more tasks"
end
