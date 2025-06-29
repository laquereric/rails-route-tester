require "rails"

module RailsRouteTester
  class RouteAnalyzer
    attr_reader :routes, :route_test_mapping

    def initialize
      @routes = []
      @route_test_mapping = {}
      load_routes
      analyze_existing_tests
    end

    # Get all routes from Rails application
    def load_routes
      return unless defined?(Rails) && Rails.application

      Rails.application.reload_routes!
      @routes = Rails.application.routes.routes.map do |route|
        {
          name: route.name,
          verb: route.verb,
          path: route.path.spec.to_s,
          controller: route.defaults[:controller],
          action: route.defaults[:action],
          requirements: route.requirements,
          constraints: route.constraints
        }
      end.reject { |route| route[:controller].nil? }
    end

    # List all routes in a formatted way
    def list_routes
      @routes.map do |route|
        {
          name: route[:name] || "unnamed",
          method: route[:verb],
          path: clean_path(route[:path]),
          controller: route[:controller],
          action: route[:action],
          full_path: "#{route[:controller]}##{route[:action]}"
        }
      end
    end

    # Find existing test files for routes
    def analyze_existing_tests
      @routes.each do |route|
        controller = route[:controller]
        action = route[:action]
        
        @route_test_mapping[route] = {
          rspec_files: find_rspec_tests(controller, action),
          cucumber_files: find_cucumber_tests(controller, action),
          pom_files: find_pom_files(controller, action)
        }
      end
    end

    # Get routes with their associated tests
    def routes_with_tests
      list_routes.map do |route|
        original_route = @routes.find { |r| r[:controller] == route[:controller] && r[:action] == route[:action] }
        tests = @route_test_mapping[original_route] || {}
        
        route.merge(
          rspec_tests: tests[:rspec_files] || [],
          cucumber_tests: tests[:cucumber_files] || [],
          pom_files: tests[:pom_files] || []
        )
      end
    end

    # Get routes without any tests
    def routes_without_tests
      routes_with_tests.select do |route|
        route[:rspec_tests].empty? && route[:cucumber_tests].empty?
      end
    end

    # Get routes without POMs
    def routes_without_poms
      routes_with_tests.select do |route|
        route[:pom_files].empty?
      end
    end

    private

    def clean_path(path)
      path.gsub(/\(\.:format\)$/, "").gsub(/\A\//, "")
    end

    def find_rspec_tests(controller, action)
      test_files = []
      
      # Look for controller specs
      controller_spec_path = "spec/controllers/#{controller}_controller_spec.rb"
      test_files << controller_spec_path if File.exist?(controller_spec_path)
      
      # Look for feature specs
      feature_spec_path = "spec/features/#{controller}_#{action}_spec.rb"
      test_files << feature_spec_path if File.exist?(feature_spec_path)
      
      # Look for request specs
      request_spec_path = "spec/requests/#{controller}_spec.rb"
      test_files << request_spec_path if File.exist?(request_spec_path)
      
      # Look for system specs
      system_spec_path = "spec/system/#{controller}_spec.rb"
      test_files << system_spec_path if File.exist?(system_spec_path)
      
      test_files
    end

    def find_cucumber_tests(controller, action)
      test_files = []
      
      # Look for feature files
      feature_path = "features/#{controller}_#{action}.feature"
      test_files << feature_path if File.exist?(feature_path)
      
      # Look for controller-specific features
      controller_feature_path = "features/#{controller}.feature"
      test_files << controller_feature_path if File.exist?(controller_feature_path)
      
      test_files
    end

    def find_pom_files(controller, action)
      pom_files = []
      
      # Look for page object files
      pom_path = "#{RailsRouteTester.configuration.pom_base_path}/#{controller}_#{action}_page.rb"
      pom_files << pom_path if File.exist?(pom_path)
      
      # Look for controller-specific POMs
      controller_pom_path = "#{RailsRouteTester.configuration.pom_base_path}/#{controller}_page.rb"
      pom_files << controller_pom_path if File.exist?(controller_pom_path)
      
      pom_files
    end

    def rails_root
      return Rails.root if defined?(Rails) && Rails.root
      Dir.pwd
    end
  end
end

