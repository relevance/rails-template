require 'spec_helper'

require File.dirname(__FILE__) + '/../../recipes/exception_notification.rb'


describe ExceptionNotification do
  let(:generator) { mock("generator").as_null_object }
  subject { ExceptionNotification.new(generator, config) }

  describe '.config_switch' do
    context "when coalmine" do
      let(:config) {{'exception_notification' => 'coalmine'}}
      
      it "it respects basic config options" do
        generator.should_receive("gem").with("coalmine", anything)

        subject.config_switch
        config.should have_key("api_key")
      end
    end

    context "when airbrake" do
      let(:config) {{'exception_notification' => 'airbrake'}}

      it "it respects basic config options" do
        generator.should_receive("gem").with("airbrake", anything)

        subject.config_switch
        config.should have_key("api_key")
        config.should have_key("host")
      end
    end
  end
end
