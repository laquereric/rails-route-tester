require 'spec_helper'

RSpec.describe RailsRouteTester do
  it "has a version number" do
    expect(RailsRouteTester::VERSION).not_to be nil
  end

  describe "configuration" do
    it "has default configuration values" do
      config = RailsRouteTester.configuration
      expect(config.pom_base_path).to eq("spec/support/page_objects")
      expect(config.spec_base_path).to eq("spec/features")
      expect(config.features_base_path).to eq("features")
      expect(config.test_framework).to eq(:rspec)
    end

    it "allows configuration changes" do
      RailsRouteTester.configure do |config|
        config.pom_base_path = "test/page_objects"
        config.test_framework = :cucumber
      end

      config = RailsRouteTester.configuration
      expect(config.pom_base_path).to eq("test/page_objects")
      expect(config.test_framework).to eq(:cucumber)
    end
  end
end
