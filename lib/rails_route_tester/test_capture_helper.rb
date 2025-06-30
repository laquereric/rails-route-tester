require "fileutils"
require "time"

module RailsRouteTester
  module TestCaptureHelper
    class << self
      def capture_test_results(example_name, step_name = nil)
        timestamp = Time.current.strftime("%Y%m%d_%H%M%S_%L")
        test_id = "#{example_name.gsub(/[^a-zA-Z0-9]/, '_')}_#{timestamp}"
        
        # Create results directory structure
        results_dir = "route_tests_results/#{test_id}"
        ensure_directory_exists(results_dir)
        
        # Capture HTML
        html_path = capture_html(results_dir, test_id, step_name)
        
        # Capture PNG screenshot
        png_path = capture_screenshot(results_dir, test_id, step_name)
        
        # Create metadata file
        metadata_path = create_metadata(results_dir, test_id, example_name, step_name, html_path, png_path)
        
        {
          test_id: test_id,
          html_path: html_path,
          png_path: png_path,
          metadata_path: metadata_path,
          results_dir: results_dir
        }
      end

      def capture_html(results_dir, test_id, step_name = nil)
        filename = step_name ? "#{test_id}_#{step_name.gsub(/[^a-zA-Z0-9]/, '_')}.html" : "#{test_id}.html"
        html_path = File.join(results_dir, filename)
        
        # Get current page HTML
        html_content = page.html
        
        # Add metadata to HTML
        enhanced_html = enhance_html_with_metadata(html_content, test_id, step_name)
        
        File.write(html_path, enhanced_html)
        html_path
      end

      def capture_screenshot(results_dir, test_id, step_name = nil)
        filename = step_name ? "#{test_id}_#{step_name.gsub(/[^a-zA-Z0-9]/, '_')}.png" : "#{test_id}.png"
        png_path = File.join(results_dir, filename)
        
        # Take screenshot
        page.save_screenshot(png_path, full: true)
        png_path
      end

      def create_metadata(results_dir, test_id, example_name, step_name, html_path, png_path)
        metadata_path = File.join(results_dir, "#{test_id}_metadata.json")
        
        metadata = {
          test_id: test_id,
          example_name: example_name,
          step_name: step_name,
          timestamp: Time.current.iso8601,
          current_url: page.current_url,
          page_title: page.title,
          files: {
            html: html_path,
            png: png_path
          },
          browser_info: {
            user_agent: page.driver.browser&.execute_script("return navigator.userAgent;") rescue "Unknown",
            window_size: page.driver.browser&.manage&.window&.size rescue nil
          }
        }
        
        File.write(metadata_path, JSON.pretty_generate(metadata))
        metadata_path
      end

      def enhance_html_with_metadata(html_content, test_id, step_name)
        # Add metadata as HTML comments and a visible overlay
        metadata_comment = "<!-- Test Capture Metadata: test_id=#{test_id}, step_name=#{step_name}, timestamp=#{Time.current.iso8601} -->"
        
        # Create a simple overlay div with metadata
        overlay_html = <<~HTML
          <div style="position: fixed; top: 0; left: 0; background: rgba(0,0,0,0.8); color: white; padding: 10px; font-family: monospace; font-size: 12px; z-index: 9999; max-width: 100%; word-wrap: break-word;">
            <strong>Test Capture:</strong> #{test_id}<br>
            <strong>Step:</strong> #{step_name || 'N/A'}<br>
            <strong>Time:</strong> #{Time.current.strftime("%Y-%m-%d %H:%M:%S")}<br>
            <strong>URL:</strong> #{page.current_url}
          </div>
        HTML
        
        # Insert metadata comment and overlay into HTML
        html_content.gsub(/<body[^>]*>/, "\\0\n#{metadata_comment}\n#{overlay_html}")
      end

      def ensure_directory_exists(directory)
        FileUtils.mkdir_p(directory) unless File.directory?(directory)
      end

      def cleanup_old_results(keep_days = 7)
        results_dir = "route_tests_results"
        return unless File.directory?(results_dir)
        
        cutoff_time = Time.current - (keep_days * 24 * 60 * 60)
        
        Dir.entries(results_dir).each do |entry|
          next if entry == "." || entry == ".."
          
          entry_path = File.join(results_dir, entry)
          if File.directory?(entry_path)
            # Extract timestamp from directory name
            if entry =~ /_(\d{8}_\d{6}_\d{3})$/
              timestamp_str = $1
              begin
                timestamp = Time.strptime(timestamp_str, "%Y%m%d_%H%M%S_%L")
                if timestamp < cutoff_time
                  FileUtils.rm_rf(entry_path)
                  puts "Cleaned up old test results: #{entry_path}"
                end
              rescue ArgumentError
                # Skip if timestamp parsing fails
              end
            end
          end
        end
      end
    end
  end
end 