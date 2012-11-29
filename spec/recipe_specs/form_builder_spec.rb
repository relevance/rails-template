require 'spec_helper'


test_generator do
  testing_recipe "form_builder" do
    prefs :admin => 'true'
  end

  specify "Gemfile contains 'formtastic'" do
    file_contains 'Gemfile', 'formtastic'
  end
end

test_generator do
  testing_recipe "form_builder" do
    prefs :admin => 'false'
  end

  specify "Gemfile omits 'formtastic'" do
    file_omits 'Gemfile', 'formtastic'
  end
end
