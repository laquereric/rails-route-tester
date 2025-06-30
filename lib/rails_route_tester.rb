require "rails_route_tester/version"
require "rails_route_tester/route_analyzer"
require "rails_route_tester/test_finder"
require "rails_route_tester/test_capture_helper"
require "rails_route_tester/generators/pom_generator"
require "rails_route_tester/generators/rspec_generator"
require "rails_route_tester/generators/cucumber_generator"

module RailsRouteTester
  class Error < StandardError; end

  # Main entry point for the gem
  class << self
    def configure
      yield(configuration) if block_given?
    end

    def configuration
      @configuration ||= Configuration.new
    end
  end

  class Configuration
    attr_accessor :pom_base_path, :spec_base_path, :features_base_path, :test_framework

    def initialize
      @pom_base_path = "spec/support/page_objects"
      @spec_base_path = "spec/features"
      @features_base_path = "features"
      @test_framework = :rspec # or :cucumber
    end
  end
end

# Load rake tasks if we're in a Rails environment
if defined?(Rails)
  require "rails_route_tester/railtie"
end

