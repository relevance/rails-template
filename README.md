## High-level workflow

'Template developers' -- folks working on this project -- run rails_app_composer and choose which recipes to bake into the template.rb file it outputs. 

These recipes thereby become available to external application developers wishing to jumpstart a new rails app by choosing, e.g. a Heroku stack vs an EC2 stack.


## Current state of this code

Gradually un-spaghettifying. 

The original codebase assumes a bedrock layer of in-house recipes with the ability to layer in optional custom recipes. We'd prefer to see all recipe logic, including built-in logic, exist as stand-alone recipes with a tiny bit of controller code to route amongst them. As we improve the code, we're taking the opportunity to untangle the older bits accordingly.

An unfortunate reality of Rails application templates is that the output template.rb file works best as a single file, so the basic function of rails_app_composer is to spit the chosen code portions -- "recipes" -- into the resulting template.rb, making them available to the application developer later down the road.

These recipes are then switched on and off at 'rails new'-time via the prefs object. (See the 'Recipes' section for more detail.)

This prefs system is simple and effective but as we add more inter-recipe logic, avoiding brittle spaghetti code should be a chief concern.


## Recipes

### Single namespace
Note that recipes become a shared namespace! Setting, say, a VERSION constant in recipe X would be a bad idea -- recipe Y may clobber it. Favor prepending the recipe name to any constants/variables for cheap namespacing.

### Recipe logistics
Rails App Composer has some slightly different assumptions about the way the world needs to work. From [Anatomy of a Recipe](http://railsapps.github.com/tutorial-rails-apps-composer.html#Anatomy), this is a standard YAML prompt...

    config:
      - mars_test:
          type: boolean
          prompt: Do you also want to test your application on Mars?
          if: space_test
          if_recipe: mars_lander   

Here, the 'mars_test' prompt will be skipped if the mars_lander recipe is available. This isn't that helpful; our typical need is to skip a prompt if the recipe was *selected* for use in the template.

That is, we don't care much about recipe availability (there's no good reason all recipes can't be available) -- we care about what the user has chosen from the recipes and how that should affect later recipes.

Our tack has been to avoid this YAML prompt facility entirely, using our own prompts within setup.rb, and altering the prefs object from within a recipe to affect later recipes. 

For example, if we want the Active Admin to be optional -- not prompted -- and if the external application developer chooses it, then we want to also install form_builder, then setup.rb would include...

    prefs[:admin] = yes_wizard? "Do you want to install ActiveAdmin?" unless prefs.has_key? :admin

(The conditional prefs.has_key? check at the end allows this prompt to be nullified via defaults.yml.)

Then in the active_admin recipe, we can conditionally direct the form_builder recipe to run like so...

    prefs[:form_builder] = true

For this to have the desired effect, the form_builder recipe must run_after the heroku recipe.


## Testing

We have identified two or three worthwhile testing patterns, none of which are fully implemented.

#### A) Recipe unit-testing

Testing a stand-alone recipe. Recipes are sufficiently low-complexity that these tests will probably consist largely of ensuring that the path through the code, given the desired inputs, is correct.

PROS: Easy. Fast.
CONS: Of limited value. Making a recipe's functions testable in isolation seems to require class structure, which makes recipes slightly less transparent to the new reader.

#### B) Recipe integration testing

Testing one or more recipes by driving the Rails App Generator code to actually generate a new Rails app with the given inputs, then asserting various of its contents.

PROS: Can test recipe combinations. This is important when, say, the Heroku recipe must dictate that no form-builder option be present. Uses built-in framework that includes some niceties like auto-clean-up.
CONS: Much slower than unit tests -- 6 seconds instead of 20 milliseconds.

#### C) Full-blown integration testing

A set of tests running nightly on a CI server that generate a Rails App with particular inputs, then interacts with that app to ensure our expectations are met.

PROS: End-to-end testing.
CONS: Trail not yet blazed. Will presumably require non-trivial amount of work up-front and potentially on-going for each new test.

Building new recipes is a fabulous opportunity to prove out these and other testing ideas.


## Defaults.yml

What does defaults.yml do? What does specifying a recipe there mean? Are prefs important? These should be documented.


# Relevance Rails Template

You like making Rails apps? I like making Rails apps!!!!!!!!!!!

You want to make a Rails app with me?

    rails new so_many_guitars -m https://raw.github.com/relevance/rails-template/master/template.rb
    
You want to make a new template??? Why????

    bundle install
    make
    
WHOA!!!!!!!!!!

## How to write good recipes

* Simple is better than complex.
* Try to put all decisions related to a question into one recipe.
** Use `after_bundler` and `after_everything` hooks for this. `after_bundler` is for running generators and file manipulation. `after_everything` is for running db migrations and other rake tasks.
* Use `~>` for pinning most gems. Do not pin dev-only gems like `pry`.
