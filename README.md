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
