module RailsRouteTester
  class TestFinder
    class << self
      # Find all test files that might be related to a specific route
      def find_related_tests(controller, action)
        {
          rspec: find_rspec_files(controller, action),
          cucumber: find_cucumber_files(controller, action),
          minitest: find_minitest_files(controller, action)
        }
      end

      # Search for RSpec files that test a specific controller/action
      def find_rspec_files(controller, action)
        files = []
        
        # Search in spec directory
        spec_patterns = [
          "spec/**/*#{controller}*spec.rb",
          "spec/**/*#{action}*spec.rb",
          "spec/**/*#{controller}_#{action}*spec.rb"
        ]
        
        spec_patterns.each do |pattern|
          files.concat(Dir.glob(pattern))
        end
        
        # Filter files that actually contain references to the controller/action
        files.select { |file| file_contains_reference?(file, controller, action) }
      end

      # Search for Cucumber files that test a specific controller/action
      def find_cucumber_files(controller, action)
        files = []
        
        # Search in features directory
        feature_patterns = [
          "features/**/*#{controller}*.feature",
          "features/**/*#{action}*.feature",
          "features/**/*#{controller}_#{action}*.feature"
        ]
        
        feature_patterns.each do |pattern|
          files.concat(Dir.glob(pattern))
        end
        
        # Also look for step definitions
        step_patterns = [
          "features/step_definitions/**/*#{controller}*steps.rb",
          "features/step_definitions/**/*#{action}*steps.rb"
        ]
        
        step_patterns.each do |pattern|
          files.concat(Dir.glob(pattern))
        end
        
        files.select { |file| file_contains_reference?(file, controller, action) }
      end

      # Search for Minitest files
      def find_minitest_files(controller, action)
        files = []
        
        test_patterns = [
          "test/**/*#{controller}*test.rb",
          "test/**/*#{action}*test.rb",
          "test/**/*#{controller}_#{action}*test.rb"
        ]
        
        test_patterns.each do |pattern|
          files.concat(Dir.glob(pattern))
        end
        
        files.select { |file| file_contains_reference?(file, controller, action) }
      end

      # Check if a file contains references to the controller or action
      def file_contains_reference?(file_path, controller, action)
        return false unless File.exist?(file_path)
        
        content = File.read(file_path)
        
        # Check for various patterns that might indicate the file tests this route
        patterns = [
          /#{controller}/i,
          /#{action}/i,
          /#{controller.camelize}/,
          /#{controller.camelize}Controller/,
          /#{controller}_path/,
          /#{controller}_url/,
          /visit.*#{controller}/,
          /get.*#{controller}/,
          /post.*#{controller}/,
          /put.*#{controller}/,
          /patch.*#{controller}/,
          /delete.*#{controller}/
        ]
        
        patterns.any? { |pattern| content.match?(pattern) }
      end

      # Get test coverage statistics
      def test_coverage_stats
        analyzer = RouteAnalyzer.new
        routes = analyzer.list_routes
        
        total_routes = routes.count
        routes_with_rspec = 0
        routes_with_cucumber = 0
        routes_with_any_test = 0
        
        routes.each do |route|
          tests = find_related_tests(route[:controller], route[:action])
          
          has_rspec = !tests[:rspec].empty?
          has_cucumber = !tests[:cucumber].empty?
          has_any = has_rspec || has_cucumber || !tests[:minitest].empty?
          
          routes_with_rspec += 1 if has_rspec
          routes_with_cucumber += 1 if has_cucumber
          routes_with_any_test += 1 if has_any
        end
        
        {
          total_routes: total_routes,
          routes_with_rspec: routes_with_rspec,
          routes_with_cucumber: routes_with_cucumber,
          routes_with_any_test: routes_with_any_test,
          rspec_coverage: total_routes > 0 ? (routes_with_rspec.to_f / total_routes * 100).round(2) : 0,
          cucumber_coverage: total_routes > 0 ? (routes_with_cucumber.to_f / total_routes * 100).round(2) : 0,
          overall_coverage: total_routes > 0 ? (routes_with_any_test.to_f / total_routes * 100).round(2) : 0
        }
      end
    end
  end
end

