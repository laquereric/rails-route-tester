namespace :tests do
  namespace :generate do
    desc "Generate RSpec feature test for a specific route"
    task :rspec, [:controller, :action] => :environment do |t, args|
      if args[:controller].nil? || args[:action].nil?
        puts "Usage: rake tests:generate:rspec[controller,action]"
        puts "Example: rake tests:generate:rspec[users,index]"
        next
      end

      generator = RailsRouteTester::Generators::RspecGenerator.new
      
      begin
        test_path = generator.generate_feature_test_for_route(args[:controller], args[:action])
        
        if test_path
          puts "RSpec feature test generated successfully!"
          puts "File: #{test_path}"
          puts ""
          puts "The test includes:"
          puts "- Page Object Model integration"
          puts "- Action-specific test scenarios"
          puts "- Shared examples for common validations"
          puts "- Screenshot capabilities"
          puts ""
          puts "To run the test:"
          puts "  rspec #{test_path}"
        else
          puts "Failed to generate test. Route not found: #{args[:controller]}##{args[:action]}"
        end
      rescue => e
        puts "Error generating RSpec test: #{e.message}"
        puts e.backtrace if ENV['DEBUG']
      end
    end

    desc "Generate Cucumber feature test for a specific route"
    task :cucumber, [:controller, :action] => :environment do |t, args|
      if args[:controller].nil? || args[:action].nil?
        puts "Usage: rake tests:generate:cucumber[controller,action]"
        puts "Example: rake tests:generate:cucumber[users,index]"
        next
      end

      generator = RailsRouteTester::Generators::CucumberGenerator.new
      
      begin
        files = generator.generate_feature_test_for_route(args[:controller], args[:action])
        
        if files && files.any?
          puts "Cucumber feature test generated successfully!"
          puts "Files:"
          files.each { |file| puts "  - #{file}" }
          puts ""
          puts "The test includes:"
          puts "- Gherkin feature scenarios"
          puts "- Step definitions with POM integration"
          puts "- Background setup and data management"
          puts "- Action-specific test scenarios"
          puts ""
          puts "To run the test:"
          puts "  cucumber #{files.first}"
        else
          puts "Failed to generate test. Route not found: #{args[:controller]}##{args[:action]}"
        end
      rescue => e
        puts "Error generating Cucumber test: #{e.message}"
        puts e.backtrace if ENV['DEBUG']
      end
    end

    desc "Generate both RSpec and Cucumber tests for a specific route"
    task :both, [:controller, :action] => :environment do |t, args|
      if args[:controller].nil? || args[:action].nil?
        puts "Usage: rake tests:generate:both[controller,action]"
        puts "Example: rake tests:generate:both[users,index]"
        next
      end

      puts "Generating both RSpec and Cucumber tests for #{args[:controller]}##{args[:action]}..."
      puts "=" * 70

      # Generate RSpec test
      Rake::Task["tests:generate:rspec"].invoke(args[:controller], args[:action])
      
      puts "\n" + "-" * 40 + "\n"
      
      # Generate Cucumber test
      Rake::Task["tests:generate:cucumber"].invoke(args[:controller], args[:action])
    end

    desc "Generate RSpec feature tests for all routes"
    task :rspec_all => :environment do
      generator = RailsRouteTester::Generators::RspecGenerator.new
      
      puts "Generating RSpec feature tests for all routes..."
      puts "=" * 60

      # Generate support files first
      support_files = generator.generate_support_files
      puts "Support files:"
      support_files.each { |file| puts "  - #{file}" }

      # Generate tests for all routes
      generated_files = generator.generate_all_feature_tests
      
      if generated_files.any?
        puts "\nGenerated #{generated_files.count} RSpec feature tests:"
        generated_files.each { |file| puts "  - #{file}" }
        
        puts "\nTo run all feature tests:"
        puts "  rspec spec/features/"
      else
        puts "No RSpec tests were generated. Check if routes exist in your application."
      end
    end

    desc "Generate Cucumber feature tests for all routes"
    task :cucumber_all => :environment do
      generator = RailsRouteTester::Generators::CucumberGenerator.new
      
      puts "Generating Cucumber feature tests for all routes..."
      puts "=" * 60

      # Generate support files first
      support_files = generator.generate_support_files
      puts "Support files:"
      support_files.each { |file| puts "  - #{file}" }

      # Generate tests for all routes
      generated_files = generator.generate_all_feature_tests
      
      if generated_files.any?
        puts "\nGenerated #{generated_files.count} Cucumber files:"
        generated_files.each { |file| puts "  - #{file}" }
        
        puts "\nTo run all Cucumber tests:"
        puts "  cucumber features/"
      else
        puts "No Cucumber tests were generated. Check if routes exist in your application."
      end
    end

    desc "Generate both RSpec and Cucumber tests for all routes"
    task :all => :environment do
      puts "Generating comprehensive test suite for all routes..."
      puts "=" * 70

      # Generate POMs first
      puts "Step 1: Generating Page Object Models..."
      Rake::Task["pom:generate:all"].invoke
      
      puts "\n" + "=" * 70
      puts "Step 2: Generating RSpec feature tests..."
      Rake::Task["tests:generate:rspec_all"].invoke
      
      puts "\n" + "=" * 70
      puts "Step 3: Generating Cucumber feature tests..."
      Rake::Task["tests:generate:cucumber_all"].invoke
      
      puts "\n" + "=" * 70
      puts "TEST SUITE GENERATION COMPLETE!"
      puts "=" * 70
      puts ""
      puts "Your Rails application now has:"
      puts "✓ Page Object Models for all routes"
      puts "✓ RSpec feature tests with POM integration"
      puts "✓ Cucumber feature tests with step definitions"
      puts "✓ Support files and configuration"
      puts ""
      puts "Next steps:"
      puts "1. Review and customize the generated tests"
      puts "2. Update POMs to match your application's UI"
      puts "3. Add FactoryBot factories for your models"
      puts "4. Run the tests: 'rspec spec/features/' or 'cucumber features/'"
    end
  end

  desc "List all existing test files"
  task :list => :environment do
    puts "\n" + "=" * 60
    puts "EXISTING TEST FILES"
    puts "=" * 60

    # List RSpec files
    rspec_base = RailsRouteTester.configuration.spec_base_path
    puts "\nRSpec Feature Tests (#{rspec_base}):"
    if Dir.exist?(rspec_base)
      rspec_files = Dir.glob(File.join(rspec_base, "**", "*_spec.rb"))
      if rspec_files.any?
        rspec_files.sort.each { |file| puts "  - #{file.sub("#{Dir.pwd}/", "")}" }
        puts "  Total: #{rspec_files.count} files"
      else
        puts "  No RSpec feature tests found."
      end
    else
      puts "  Directory does not exist."
    end

    # List Cucumber files
    cucumber_base = RailsRouteTester.configuration.features_base_path
    puts "\nCucumber Features (#{cucumber_base}):"
    if Dir.exist?(cucumber_base)
      feature_files = Dir.glob(File.join(cucumber_base, "**", "*.feature"))
      step_files = Dir.glob(File.join(cucumber_base, "step_definitions", "**", "*_steps.rb"))
      
      if feature_files.any?
        puts "  Feature files:"
        feature_files.sort.each { |file| puts "    - #{file.sub("#{Dir.pwd}/", "")}" }
      end
      
      if step_files.any?
        puts "  Step definition files:"
        step_files.sort.each { |file| puts "    - #{file.sub("#{Dir.pwd}/", "")}" }
      end
      
      total_cucumber = feature_files.count + step_files.count
      puts "  Total: #{total_cucumber} files" if total_cucumber > 0
      
      if feature_files.empty? && step_files.empty?
        puts "  No Cucumber tests found."
      end
    else
      puts "  Directory does not exist."
    end

    # List POM files
    pom_base = RailsRouteTester.configuration.pom_base_path
    puts "\nPage Object Models (#{pom_base}):"
    if Dir.exist?(pom_base)
      pom_files = Dir.glob(File.join(pom_base, "**", "*_page.rb"))
      if pom_files.any?
        pom_files.sort.each { |file| puts "  - #{file.sub("#{Dir.pwd}/", "")}" }
        puts "  Total: #{pom_files.count} files"
      else
        puts "  No Page Object Models found."
      end
    else
      puts "  Directory does not exist."
    end
  end

  desc "Run all RSpec feature tests"
  task :run_rspec => :environment do
    rspec_base = RailsRouteTester.configuration.spec_base_path
    
    if Dir.exist?(rspec_base) && Dir.glob(File.join(rspec_base, "**", "*_spec.rb")).any?
      puts "Running RSpec feature tests..."
      system("rspec #{rspec_base}")
    else
      puts "No RSpec feature tests found. Run 'rake tests:generate:rspec_all' first."
    end
  end

  desc "Run all Cucumber feature tests"
  task :run_cucumber => :environment do
    cucumber_base = RailsRouteTester.configuration.features_base_path
    
    if Dir.exist?(cucumber_base) && Dir.glob(File.join(cucumber_base, "**", "*.feature")).any?
      puts "Running Cucumber feature tests..."
      system("cucumber #{cucumber_base}")
    else
      puts "No Cucumber feature tests found. Run 'rake tests:generate:cucumber_all' first."
    end
  end

  desc "Run all tests (RSpec and Cucumber)"
  task :run_all => :environment do
    puts "Running complete test suite..."
    puts "=" * 50

    puts "\n1. Running RSpec feature tests..."
    Rake::Task["tests:run_rspec"].invoke
    
    puts "\n" + "=" * 50
    puts "2. Running Cucumber feature tests..."
    Rake::Task["tests:run_cucumber"].invoke
    
    puts "\n" + "=" * 50
    puts "Test suite execution complete!"
  end

  desc "Clean up unused test files"
  task :cleanup => :environment do
    analyzer = RailsRouteTester::RouteAnalyzer.new
    current_routes = analyzer.list_routes
    
    puts "\n" + "=" * 60
    puts "CLEANING UP UNUSED TEST FILES"
    puts "=" * 60

    unused_files = []

    # Check RSpec files
    rspec_base = RailsRouteTester.configuration.spec_base_path
    if Dir.exist?(rspec_base)
      rspec_files = Dir.glob(File.join(rspec_base, "**", "*_spec.rb"))
      rspec_files.each do |file|
        filename = File.basename(file, "_spec.rb")
        if filename.match(/^(.+)_(.+)$/)
          controller, action = $1, $2
          route_exists = current_routes.any? do |route|
            route[:controller] == controller && route[:action] == action
          end
          unused_files << file unless route_exists
        end
      end
    end

    # Check Cucumber files
    cucumber_base = RailsRouteTester.configuration.features_base_path
    if Dir.exist?(cucumber_base)
      feature_files = Dir.glob(File.join(cucumber_base, "**", "*.feature"))
      feature_files.each do |file|
        filename = File.basename(file, ".feature")
        if filename.match(/^(.+)_(.+)$/)
          controller, action = $1, $2
          route_exists = current_routes.any? do |route|
            route[:controller] == controller && route[:action] == action
          end
          unused_files << file unless route_exists
        end
      end

      step_files = Dir.glob(File.join(cucumber_base, "step_definitions", "**", "*_steps.rb"))
      step_files.each do |file|
        filename = File.basename(file, "_steps.rb")
        if filename.match(/^(.+)_(.+)$/)
          controller, action = $1, $2
          route_exists = current_routes.any? do |route|
            route[:controller] == controller && route[:action] == action
          end
          unused_files << file unless route_exists
        end
      end
    end

    if unused_files.any?
      puts "Found #{unused_files.count} unused test files:"
      unused_files.each { |file| puts "  - #{file.sub("#{Dir.pwd}/", "")}" }
      
      print "\nDelete these files? (y/N): "
      response = STDIN.gets.chomp.downcase
      
      if response == 'y' || response == 'yes'
        unused_files.each do |file|
          File.delete(file)
          puts "Deleted: #{file.sub("#{Dir.pwd}/", "")}"
        end
        puts "Cleanup completed."
      else
        puts "Cleanup cancelled."
      end
    else
      puts "No unused test files found."
    end
  end
end

