namespace :pom do
  desc "Generate Page Object Model for a specific route"
  task :generate, [:controller, :action] => :environment do |t, args|
    if args[:controller].nil? || args[:action].nil?
      puts "Usage: rake pom:generate[controller,action]"
      puts "Example: rake pom:generate[users,index]"
      next
    end

    generator = RailsRouteTester::Generators::PomGenerator.new
    
    begin
      # Generate base POM if it doesn't exist
      base_path = generator.generate_base_pom
      puts "Base POM created at: #{base_path}" if base_path

      # Generate specific POM
      pom_path = generator.generate_pom_for_route(args[:controller], args[:action])
      
      if pom_path
        puts "Page Object Model generated successfully!"
        puts "File: #{pom_path}"
        puts ""
        puts "Next steps:"
        puts "1. Customize the page elements in the generated POM"
        puts "2. Add specific page actions for your application"
        puts "3. Update validations based on your page requirements"
        puts "4. Generate tests using: rake tests:generate:rspec[#{args[:controller]},#{args[:action]}]"
      else
        puts "Failed to generate POM. Route not found: #{args[:controller]}##{args[:action]}"
      end
    rescue => e
      puts "Error generating POM: #{e.message}"
      puts e.backtrace if ENV['DEBUG']
    end
  end

  namespace :generate do
    desc "Generate Page Object Models for all routes"
    task :all => :environment do
      generator = RailsRouteTester::Generators::PomGenerator.new
      
      puts "Generating Page Object Models for all routes..."
      puts "=" * 60

      # Generate base POM first
      base_path = generator.generate_base_pom
      puts "Base POM: #{base_path}"

      # Generate POMs for all routes
      generated_files = generator.generate_all_poms
      
      if generated_files.any?
        puts "\nGenerated #{generated_files.count} Page Object Models:"
        generated_files.each { |file| puts "  - #{file}" }
        
        puts "\nNext steps:"
        puts "1. Review and customize the generated POMs"
        puts "2. Update page elements to match your application"
        puts "3. Generate tests using: rake tests:generate:all"
      else
        puts "No POMs were generated. Check if routes exist in your application."
      end
    end

    desc "Generate POMs for routes without existing POMs"
    task :missing => :environment do
      analyzer = RailsRouteTester::RouteAnalyzer.new
      generator = RailsRouteTester::Generators::PomGenerator.new
      routes_without_poms = analyzer.routes_without_poms

      if routes_without_poms.empty?
        puts "All routes already have Page Object Models!"
        next
      end

      puts "Generating POMs for #{routes_without_poms.count} routes without POMs..."
      puts "=" * 60

      # Generate base POM first
      base_path = generator.generate_base_pom
      puts "Base POM: #{base_path}"

      generated_files = []
      routes_without_poms.each do |route|
        begin
          pom_path = generator.generate_pom_for_route(route[:controller], route[:action])
          generated_files << pom_path if pom_path
          puts "Generated: #{route[:controller]}##{route[:action]} -> #{pom_path}"
        rescue => e
          puts "Error generating POM for #{route[:controller]}##{route[:action]}: #{e.message}"
        end
      end

      puts "\nGenerated #{generated_files.count} new Page Object Models."
    end
  end

  desc "List all existing Page Object Models"
  task :list => :environment do
    pom_base_path = RailsRouteTester.configuration.pom_base_path
    
    puts "\n" + "=" * 60
    puts "EXISTING PAGE OBJECT MODELS"
    puts "=" * 60
    puts "Base path: #{pom_base_path}"

    if Dir.exist?(pom_base_path)
      pom_files = Dir.glob(File.join(pom_base_path, "**", "*_page.rb"))
      
      if pom_files.any?
        pom_files.sort.each do |file|
          relative_path = file.sub("#{Dir.pwd}/", "")
          puts "  - #{relative_path}"
        end
        puts "\nTotal POMs: #{pom_files.count}"
      else
        puts "No Page Object Models found."
        puts "Run 'rake pom:generate:all' to generate POMs for all routes."
      end
    else
      puts "POM directory does not exist: #{pom_base_path}"
      puts "Run 'rake pom:generate:all' to create POMs."
    end
  end

  desc "Validate existing Page Object Models"
  task :validate => :environment do
    pom_base_path = RailsRouteTester.configuration.pom_base_path
    
    puts "\n" + "=" * 60
    puts "VALIDATING PAGE OBJECT MODELS"
    puts "=" * 60

    if !Dir.exist?(pom_base_path)
      puts "POM directory does not exist: #{pom_base_path}"
      next
    end

    pom_files = Dir.glob(File.join(pom_base_path, "**", "*_page.rb"))
    
    if pom_files.empty?
      puts "No Page Object Models found to validate."
      next
    end

    valid_files = []
    invalid_files = []

    pom_files.each do |file|
      begin
        # Basic syntax check
        content = File.read(file)
        
        # Check for required methods/structure
        has_class_definition = content.match(/class\s+\w+Page\s*<\s*BasePage/)
        has_path_method = content.match(/def\s+self\.path/)
        has_url_method = content.match(/def\s+self\.url/)
        
        if has_class_definition && has_path_method && has_url_method
          valid_files << file
          puts "✓ #{file.sub("#{Dir.pwd}/", "")}"
        else
          invalid_files << file
          puts "✗ #{file.sub("#{Dir.pwd}/", "")} - Missing required structure"
        end
      rescue => e
        invalid_files << file
        puts "✗ #{file.sub("#{Dir.pwd}/", "")} - Syntax error: #{e.message}"
      end
    end

    puts "\nValidation Summary:"
    puts "Valid POMs: #{valid_files.count}"
    puts "Invalid POMs: #{invalid_files.count}"

    if invalid_files.any?
      puts "\nInvalid files need to be fixed or regenerated:"
      invalid_files.each { |file| puts "  - #{file.sub("#{Dir.pwd}/", "")}" }
    end
  end

  desc "Clean up unused Page Object Models"
  task :cleanup => :environment do
    analyzer = RailsRouteTester::RouteAnalyzer.new
    current_routes = analyzer.list_routes
    pom_base_path = RailsRouteTester.configuration.pom_base_path

    puts "\n" + "=" * 60
    puts "CLEANING UP UNUSED PAGE OBJECT MODELS"
    puts "=" * 60

    if !Dir.exist?(pom_base_path)
      puts "POM directory does not exist: #{pom_base_path}"
      next
    end

    pom_files = Dir.glob(File.join(pom_base_path, "**", "*_page.rb"))
    pom_files.reject! { |f| File.basename(f) == "base_page.rb" } # Keep base page

    unused_files = []

    pom_files.each do |file|
      filename = File.basename(file, ".rb")
      
      # Extract controller and action from filename (e.g., "users_index_page" -> "users", "index")
      if filename.match(/^(.+)_(.+)_page$/)
        controller, action = $1, $2
        
        # Check if route still exists
        route_exists = current_routes.any? do |route|
          route[:controller] == controller && route[:action] == action
        end
        
        unless route_exists
          unused_files << file
        end
      end
    end

    if unused_files.any?
      puts "Found #{unused_files.count} unused POM files:"
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
      puts "No unused POM files found."
    end
  end
end

