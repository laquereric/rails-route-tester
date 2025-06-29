namespace :routes do
  desc "List all routes in the application"
  task :list => :environment do
    analyzer = RailsRouteTester::RouteAnalyzer.new
    routes = analyzer.list_routes

    puts "\n" + "=" * 80
    puts "RAILS ROUTES ANALYSIS"
    puts "=" * 80

    if routes.empty?
      puts "No routes found in the application."
      next
    end

    # Calculate column widths
    name_width = [routes.map { |r| r[:name].to_s.length }.max, 15].max
    method_width = [routes.map { |r| r[:method].to_s.length }.max, 8].max
    path_width = [routes.map { |r| r[:path].to_s.length }.max, 20].max
    controller_width = [routes.map { |r| r[:full_path].to_s.length }.max, 25].max

    # Print header
    printf "%-#{name_width}s %-#{method_width}s %-#{path_width}s %-#{controller_width}s\n",
           "NAME", "METHOD", "PATH", "CONTROLLER#ACTION"
    puts "-" * (name_width + method_width + path_width + controller_width + 3)

    # Print routes
    routes.each do |route|
      printf "%-#{name_width}s %-#{method_width}s %-#{path_width}s %-#{controller_width}s\n",
             route[:name] || "",
             route[:method],
             route[:path],
             route[:full_path]
    end

    puts "\nTotal routes: #{routes.count}"
  end

  desc "List routes with their associated tests"
  task :with_tests => :environment do
    analyzer = RailsRouteTester::RouteAnalyzer.new
    routes_with_tests = analyzer.routes_with_tests

    puts "\n" + "=" * 100
    puts "ROUTES WITH ASSOCIATED TESTS"
    puts "=" * 100

    if routes_with_tests.empty?
      puts "No routes found in the application."
      next
    end

    routes_with_tests.each do |route|
      puts "\n#{route[:method]} #{route[:path]} (#{route[:full_path]})"
      puts "  Name: #{route[:name] || 'unnamed'}"
      
      if route[:rspec_tests].any?
        puts "  RSpec Tests:"
        route[:rspec_tests].each { |test| puts "    - #{test}" }
      else
        puts "  RSpec Tests: None"
      end

      if route[:cucumber_tests].any?
        puts "  Cucumber Tests:"
        route[:cucumber_tests].each { |test| puts "    - #{test}" }
      else
        puts "  Cucumber Tests: None"
      end

      if route[:pom_files].any?
        puts "  Page Objects:"
        route[:pom_files].each { |pom| puts "    - #{pom}" }
      else
        puts "  Page Objects: None"
      end
    end

    # Summary statistics
    total_routes = routes_with_tests.count
    routes_with_rspec = routes_with_tests.count { |r| r[:rspec_tests].any? }
    routes_with_cucumber = routes_with_tests.count { |r| r[:cucumber_tests].any? }
    routes_with_poms = routes_with_tests.count { |r| r[:pom_files].any? }
    routes_with_any_test = routes_with_tests.count { |r| r[:rspec_tests].any? || r[:cucumber_tests].any? }

    puts "\n" + "=" * 50
    puts "SUMMARY STATISTICS"
    puts "=" * 50
    puts "Total routes: #{total_routes}"
    puts "Routes with RSpec tests: #{routes_with_rspec} (#{(routes_with_rspec.to_f / total_routes * 100).round(1)}%)"
    puts "Routes with Cucumber tests: #{routes_with_cucumber} (#{(routes_with_cucumber.to_f / total_routes * 100).round(1)}%)"
    puts "Routes with Page Objects: #{routes_with_poms} (#{(routes_with_poms.to_f / total_routes * 100).round(1)}%)"
    puts "Routes with any tests: #{routes_with_any_test} (#{(routes_with_any_test.to_f / total_routes * 100).round(1)}%)"
    puts "Routes without tests: #{total_routes - routes_with_any_test}"
  end

  desc "List routes without any tests"
  task :without_tests => :environment do
    analyzer = RailsRouteTester::RouteAnalyzer.new
    routes_without_tests = analyzer.routes_without_tests

    puts "\n" + "=" * 80
    puts "ROUTES WITHOUT TESTS"
    puts "=" * 80

    if routes_without_tests.empty?
      puts "Great! All routes have associated tests."
      next
    end

    routes_without_tests.each do |route|
      puts "#{route[:method].ljust(8)} #{route[:path].ljust(30)} #{route[:full_path]}"
    end

    puts "\nTotal routes without tests: #{routes_without_tests.count}"
    puts "\nTo generate tests for these routes, run:"
    puts "  rake tests:generate:all"
  end

  desc "List routes without Page Object Models"
  task :without_poms => :environment do
    analyzer = RailsRouteTester::RouteAnalyzer.new
    routes_without_poms = analyzer.routes_without_poms

    puts "\n" + "=" * 80
    puts "ROUTES WITHOUT PAGE OBJECT MODELS"
    puts "=" * 80

    if routes_without_poms.empty?
      puts "Great! All routes have associated Page Object Models."
      next
    end

    routes_without_poms.each do |route|
      puts "#{route[:method].ljust(8)} #{route[:path].ljust(30)} #{route[:full_path]}"
    end

    puts "\nTotal routes without POMs: #{routes_without_poms.count}"
    puts "\nTo generate POMs for these routes, run:"
    puts "  rake pom:generate:all"
  end

  desc "Show test coverage statistics"
  task :coverage => :environment do
    stats = RailsRouteTester::TestFinder.test_coverage_stats

    puts "\n" + "=" * 60
    puts "TEST COVERAGE STATISTICS"
    puts "=" * 60
    puts "Total routes: #{stats[:total_routes]}"
    puts ""
    puts "RSpec Coverage:"
    puts "  Routes with RSpec tests: #{stats[:routes_with_rspec]}"
    puts "  Coverage percentage: #{stats[:rspec_coverage]}%"
    puts ""
    puts "Cucumber Coverage:"
    puts "  Routes with Cucumber tests: #{stats[:routes_with_cucumber]}"
    puts "  Coverage percentage: #{stats[:cucumber_coverage]}%"
    puts ""
    puts "Overall Coverage:"
    puts "  Routes with any tests: #{stats[:routes_with_any_test]}"
    puts "  Coverage percentage: #{stats[:overall_coverage]}%"
    puts ""

    if stats[:overall_coverage] < 100
      puts "Recommendations:"
      puts "- Run 'rake routes:without_tests' to see untested routes"
      puts "- Run 'rake tests:generate:all' to generate tests for all routes"
      puts "- Run 'rake pom:generate:all' to generate Page Object Models"
    else
      puts "Excellent! You have 100% route test coverage!"
    end
  end
end

