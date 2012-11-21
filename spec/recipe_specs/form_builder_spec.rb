require 'spec_helper'


test_generator do
  testing_recipe "form_builder" do
    {'prefs' => {
        :admin => 'true',
      }}
  end

  specify "Gemfile contains 'formtastic'" do
    destination_root.should have_structure {
      file 'DIE/Gemfile' do
        contains 'formtastic'
      end
    }
  end
end

test_generator do
  testing_recipe "form_builder" do
    {'prefs' => {
        :admin => 'false',
      }}
  end

  specify "Gemfile omits 'formtastic'" do
    destination_root.should have_structure {
      file 'DIE/Gemfile' do
        omits 'formtastic'
      end
    }
  end
end
