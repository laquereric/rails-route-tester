namespace :results do
  desc "Clean up old test results (default: 7 days)"
  task :cleanup, [:days] => :environment do |t, args|
    days = (args[:days] || 7).to_i
    puts "Cleaning up test results older than #{days} days..."
    
    require 'rails_route_tester/test_capture_helper'
    RailsRouteTester::TestCaptureHelper.cleanup_old_results(days)
    
    puts "Cleanup completed!"
  end

  desc "List all test result directories"
  task :list => :environment do
    results_dir = "route_tests_results"
    
    if File.directory?(results_dir)
      puts "Test Results Directories:"
      puts "=" * 50
      
      Dir.entries(results_dir).sort.reverse.each do |entry|
        next if entry == "." || entry == ".."
        
        entry_path = File.join(results_dir, entry)
        if File.directory?(entry_path)
          # Count files in directory
          file_count = Dir.glob(File.join(entry_path, "*")).count
          
          # Try to extract timestamp and test info
          if entry =~ /(.+)_(\d{8}_\d{6}_\d{3})$/
            test_name = $1
            timestamp_str = $2
            begin
              timestamp = Time.strptime(timestamp_str, "%Y%m%d_%H%M%S_%L")
              puts "#{entry}"
              puts "  Test: #{test_name}"
              puts "  Time: #{timestamp.strftime('%Y-%m-%d %H:%M:%S')}"
              puts "  Files: #{file_count}"
              puts ""
            rescue ArgumentError
              puts "#{entry} (Files: #{file_count})"
            end
          else
            puts "#{entry} (Files: #{file_count})"
          end
        end
      end
    else
      puts "No test results directory found at #{results_dir}"
    end
  end

  desc "Show details for a specific test result"
  task :show, [:test_id] => :environment do |t, args|
    test_id = args[:test_id]
    
    if test_id.nil?
      puts "Usage: rake results:show[test_id]"
      puts "Use 'rake results:list' to see available test IDs"
      exit 1
    end
    
    results_dir = "route_tests_results/#{test_id}"
    
    if File.directory?(results_dir)
      puts "Test Result Details: #{test_id}"
      puts "=" * 50
      
      # Show metadata if available
      metadata_file = File.join(results_dir, "#{test_id}_metadata.json")
      if File.exist?(metadata_file)
        require 'json'
        metadata = JSON.parse(File.read(metadata_file))
        
        puts "Test Name: #{metadata['example_name']}"
        puts "Timestamp: #{metadata['timestamp']}"
        puts "URL: #{metadata['current_url']}"
        puts "Page Title: #{metadata['page_title']}"
        puts ""
        puts "Files:"
        puts "  HTML: #{metadata['files']['html']}"
        puts "  PNG: #{metadata['files']['png']}"
        puts ""
        puts "Browser Info:"
        puts "  User Agent: #{metadata['browser_info']['user_agent']}"
        if metadata['browser_info']['window_size']
          puts "  Window Size: #{metadata['browser_info']['window_size']}"
        end
      end
      
      # List all files in directory
      puts ""
      puts "All Files:"
      Dir.glob(File.join(results_dir, "*")).each do |file|
        size = File.size(file)
        puts "  #{File.basename(file)} (#{size} bytes)"
      end
    else
      puts "Test result directory not found: #{results_dir}"
      puts "Use 'rake results:list' to see available test IDs"
    end
  end

  desc "Open test results directory in file explorer"
  task :open => :environment do
    results_dir = "route_tests_results"
    
    if File.directory?(results_dir)
      puts "Opening test results directory..."
      
      case RbConfig::CONFIG['host_os']
      when /mswin|mingw|cygwin/
        system("start #{results_dir}")
      when /darwin/
        system("open #{results_dir}")
      when /linux|bsd/
        system("xdg-open #{results_dir}")
      else
        puts "Please open the directory manually: #{File.expand_path(results_dir)}"
      end
    else
      puts "No test results directory found at #{results_dir}"
    end
  end

  desc "Generate test results summary report"
  task :report => :environment do
    results_dir = "route_tests_results"
    
    if File.directory?(results_dir)
      puts "Test Results Summary Report"
      puts "=" * 50
      
      total_dirs = 0
      total_files = 0
      total_size = 0
      test_counts = Hash.new(0)
      
      Dir.entries(results_dir).each do |entry|
        next if entry == "." || entry == ".."
        
        entry_path = File.join(results_dir, entry)
        if File.directory?(entry_path)
          total_dirs += 1
          
          # Count files and size
          Dir.glob(File.join(entry_path, "*")).each do |file|
            total_files += 1
            total_size += File.size(file)
          end
          
          # Extract test name
          if entry =~ /(.+)_(\d{8}_\d{6}_\d{3})$/
            test_name = $1
            test_counts[test_name] += 1
          end
        end
      end
      
      puts "Total test result directories: #{total_dirs}"
      puts "Total files captured: #{total_files}"
      puts "Total size: #{format_bytes(total_size)}"
      puts ""
      
      if test_counts.any?
        puts "Tests by name:"
        test_counts.sort.each do |test_name, count|
          puts "  #{test_name}: #{count} captures"
        end
      end
      
      puts ""
      puts "Directory: #{File.expand_path(results_dir)}"
    else
      puts "No test results directory found at #{results_dir}"
    end
  end

  private

  def format_bytes(bytes)
    if bytes < 1024
      "#{bytes} B"
    elsif bytes < 1024 * 1024
      "#{(bytes / 1024.0).round(1)} KB"
    else
      "#{(bytes / (1024.0 * 1024.0)).round(1)} MB"
    end
  end
end 