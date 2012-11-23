## Goal

Provide a mechanism for generating a Rails template that offers a number of 'blessed stacks'.

## High-level workflow


'Template developers' -- folks working on this project -- run rails_app_composer and choose which recipes and prefs to bake into the template.rb file it outputs. 

This template.rb makes these recipes available to 'external application developers' -- folks wishing to jumpstart a new rails app by choosing, e.g. a Heroku stack vs an EC2 stack.

## Template preparation

`make clean template.rb` will ingest `defaults.yml` and output a `template.rb` file. All recipes named in `defaults.yml` will be inlined (but not necessarily marked for execution) in the `template.rb`. 

The `defaults.yml` is also used as the basis for a `@prefs` hash. 

The `@prefs` hash is the basic means of controlling the flow of execution.

At `rails new` time, decisions made by inline recipes will hinge on 1) the `@prefs` hash baked into the template, combined with 2) answers obtained by prompting the application developer.

## An example recipe: Adding a new stack for deploying to FooCloud

We'll pretend we want to add a recipe that describes our blessed Foo stack. We'll set webserver and email provider. We'll also decree that deployments to FooCloud shall include QuuxForm form-builder.

`setup.rb`

    prefs[:stack] = multiple_choice "Choose your stack", [["Heroku", "heroku"], ["EC2", "ec2"], ["FooCloud", "foocloud"]] unless prefs.has_key? :stack

`recipes/foocloud.rb`

    if prefer :stack, "foocloud"
      prefs[:webserver]     = "BarServer"
      prefs[:email]        = "BazMail"
      prefs[:form_builder] = "QuuxForms"
    end

    __END__

    name: foocloud
    description: "Add blessed FooCloud options."
    author: RailsApps + Relevance
    requires: [setup]
    run_after: [setup]
    category: configuration

We'll skip showing the YAML matter on the next two recipes, since it's not relevant.

`recipes/webserver.rb`

    if prefer :webserver, "BarServer"
      gem 'barserver', '~> 1.1.1'
    end

`recipes/email.rb`

    if prefer :email, "BazMail"
      gem 'bazmail, '~> 2.2.2'
      copy_from_repo some_setup_file
    end

`recipes/formbuilder.rb`

    if prefer :form_builder, "QuuxForms"
      gem 'quuxforms', '~> 3.3.3'
    end
    ...
    run_after: [setup, foocloud]
    ...

Note that the formbuilder recipe now must be told to `run_after` the foocloud recipe, so that the decision made in foocloud can affect it.


## Current state of this code

The original codebase assumes a bedrock layer of in-house recipes in `gems.rb` with the ability to layer in optional custom recipes via the /recipe directory.

We'd prefer to see all recipe logic, including built-in logic, exist as stand-alone recipes with a tiny bit of controller code in `setup.rb` to handle any prompts. As we incrementally improve the code, we're taking the opportunity to untangle the older bits accordingly. For example, the database code in `gems.rb` should be its own `recipes/database.rb` recipe.

An unfortunate reality of Rails application templates is that the output `template.rb` file works best as a single file, so the basic function of rails_app_composer is to spit the chosen code portions -- "recipes" -- into the resulting `template.rb`, making them available to the application developer later down the road.

These recipes are then switched on and off at `rails new` time via the prefs object. (See the 'Recipes' section for more detail.)

This prefs system is simple and effective but as we add more inter-recipe logic, avoiding brittle spaghetti code should be a chief concern.


## Recipe gotchas

### Single namespace
Note that recipes become a shared namespace! Setting, say, a VERSION constant in recipe X would be a bad idea -- recipe Y may clobber it. Favor prepending the recipe name to any constants/variables for cheap namespacing.

### Why we don't care about the YAML prompt facility of Rails App Composer
Rails App Composer has some slightly different assumptions about the way the world needs to work. From [Anatomy of a Recipe](http://railsapps.github.com/tutorial-rails-apps-composer.html#Anatomy), this is a standard YAML prompt...

    config:
      - mars_test:
          type: boolean
          prompt: Do you also want to test your application on Mars?
          if: space_test
          if_recipe: mars_lander   

Here, the 'mars_test' prompt will be skipped if the mars_lander recipe is available. This isn't that helpful; our typical need is to skip a prompt if the recipe was *selected* for use in the template.

That is, we don't care much about recipe availability (there's no good reason all recipes can't be available) -- we care about what the user has chosen from the recipes and how that should affect later recipes.

Our tack has been to avoid this YAML prompt facility entirely, using our own prompts within `setup.rb`, and altering the prefs object from within a recipe to affect later recipes. 

## Testing

We have identified two worthwhile testing patterns.

#### A) Recipe integration testing

Testing one or more recipes by driving the Rails App Generator code to actually generate a new Rails app with the given inputs, then asserting various of its contents.

PROS: Can test recipe combinations. This is important when, say, the Heroku recipe must dictate that no form-builder option be present. Uses built-in framework that includes some niceties like auto-clean-up.
CONS: ~1 minute per generated app.

#### B) Full-blown integration testing

A set of tests running nightly on a CI server that generate a Rails App with particular inputs, then interacts with that app to ensure our expectations are met.

PROS: End-to-end testing.
CONS: Trail not yet blazed. Will presumably require non-trivial amount of work up-front and potentially on-going for each new test.

Building new recipes is a fabulous opportunity to prove out these and other testing ideas.


# Troubleshooting

## Odd boolean handling

    if prefer :some_key

will evaluate to true even if the word `"false"` was used in the `defaults.yml`, as it will remain a string. The defaults are not currently opt-out friendly.


## Gem failure
Testing new recipes that use the `gem` command may cause template generation to fail with an error message similar to "Could not find gem 'omniauth-twitter (>= 0) ruby' in the gems available on this machine." A `gem install [gem]` will fix this.

## How to write good recipes

* Simple is better than complex.
* Try to put all decisions related to a question into one recipe.
** Use `after_bundler` and `after_everything` hooks for this. `after_bundler` is for running generators and file manipulation. `after_everything` is for running db migrations and other rake tasks.
* Use `~>` for pinning most gems. Do not pin dev-only gems like `pry`.
