require "fileutils"

module RailsRouteTester
  module Generators
    class PomGenerator
      attr_reader :route_analyzer

      def initialize
        @route_analyzer = RouteAnalyzer.new
      end

      # Generate POM for a specific route
      def generate_pom_for_route(controller, action, options = {})
        route = find_route(controller, action)
        return false unless route

        pom_content = build_pom_content(route, options)
        pom_path = pom_file_path(controller, action)
        
        ensure_directory_exists(File.dirname(pom_path))
        File.write(pom_path, pom_content)
        
        pom_path
      end

      # Generate POMs for all routes
      def generate_all_poms(options = {})
        generated_files = []
        
        @route_analyzer.list_routes.each do |route|
          begin
            file_path = generate_pom_for_route(route[:controller], route[:action], options)
            generated_files << file_path if file_path
          rescue => e
            puts "Error generating POM for #{route[:controller]}##{route[:action]}: #{e.message}"
          end
        end
        
        generated_files
      end

      # Generate base POM class if it doesn't exist
      def generate_base_pom
        base_path = File.join(RailsRouteTester.configuration.pom_base_path, "base_page.rb")
        
        unless File.exist?(base_path)
          ensure_directory_exists(File.dirname(base_path))
          File.write(base_path, base_pom_content)
        end
        
        base_path
      end

      private

      def find_route(controller, action)
        @route_analyzer.list_routes.find do |route|
          route[:controller] == controller && route[:action] == action
        end
      end

      def build_pom_content(route, options = {})
        class_name = pom_class_name(route[:controller], route[:action])
        
        template = <<~RUBY
          require_relative 'base_page'

          # Page Object Model for #{route[:controller]}##{route[:action]}
          # Route: #{route[:method]} #{route[:path]}
          class #{class_name} < BasePage
            # URL and path helpers
            def self.path
              #{path_helper_method(route)}
            end

            def self.url
              #{url_helper_method(route)}
            end

            # Page elements - customize these based on your actual page structure
            #{generate_page_elements(route, options)}

            # Page actions - customize these based on your page functionality
            #{generate_page_actions(route, options)}

            # Validations - customize these based on what you want to verify
            #{generate_page_validations(route, options)}

            private

            # Helper methods specific to this page
            #{generate_helper_methods(route, options)}
          end
        RUBY

        template
      end

      def generate_page_elements(route, options)
        elements = []
        
        # Common elements based on action type
        case route[:action]
        when 'index'
          elements << "element :search_field, 'input[type=\"search\"]'"
          elements << "element :filter_dropdown, 'select.filter'"
          elements << "elements :list_items, '.list-item'"
          elements << "element :pagination, '.pagination'"
        when 'show'
          elements << "element :title, 'h1'"
          elements << "element :edit_link, 'a[href*=\"edit\"]'"
          elements << "element :delete_link, 'a[href*=\"delete\"], button[data-method=\"delete\"]'"
        when 'new', 'create'
          elements << "element :form, 'form'"
          elements << "element :submit_button, 'input[type=\"submit\"], button[type=\"submit\"]'"
          elements << "element :cancel_link, 'a[href*=\"cancel\"], .cancel'"
        when 'edit', 'update'
          elements << "element :form, 'form'"
          elements << "element :submit_button, 'input[type=\"submit\"], button[type=\"submit\"]'"
          elements << "element :cancel_link, 'a[href*=\"cancel\"], .cancel'"
        end

        # Add common navigation elements
        elements << "element :navigation, 'nav'"
        elements << "element :flash_messages, '.flash, .alert, .notice'"
        
        elements.join("\n    ")
      end

      def generate_page_actions(route, options)
        actions = []
        
        case route[:action]
        when 'index'
          actions << <<~RUBY
            def search_for(term)
              search_field.set(term)
              search_field.send_keys(:return)
            end

            def filter_by(value)
              filter_dropdown.select(value)
            end

            def click_item(index = 0)
              list_items[index].click
            end
          RUBY
        when 'show'
          actions << <<~RUBY
            def click_edit
              edit_link.click
            end

            def click_delete
              delete_link.click
            end
          RUBY
        when 'new', 'create'
          actions << <<~RUBY
            def fill_form(data = {})
              # Customize this method based on your form fields
              data.each do |field, value|
                form.find_field(field).set(value)
              end
            end

            def submit_form
              submit_button.click
            end

            def cancel
              cancel_link.click
            end
          RUBY
        when 'edit', 'update'
          actions << <<~RUBY
            def update_form(data = {})
              # Customize this method based on your form fields
              data.each do |field, value|
                form.find_field(field).set(value)
              end
            end

            def submit_form
              submit_button.click
            end

            def cancel
              cancel_link.click
            end
          RUBY
        end

        actions.join("\n\n    ")
      end

      def generate_page_validations(route, options)
        validations = []
        
        validations << <<~RUBY
          def has_correct_title?
            # Customize this based on expected page title
            page.has_css?('h1', text: /#{route[:controller].humanize}/i)
          end

          def has_flash_message?(type = nil)
            if type
              page.has_css?(".flash.\#{type}, .alert-\#{type}, .notice") 
            else
              flash_messages.present?
            end
          end

          def loaded?
            # Customize this based on key elements that indicate page is loaded
            page.has_css?('body') && !page.has_css?('.loading')
          end
        RUBY

        case route[:action]
        when 'index'
          validations << <<~RUBY
            def has_items?
              list_items.any?
            end

            def has_search?
              search_field.present?
            end
          RUBY
        when 'show'
          validations << <<~RUBY
            def has_edit_link?
              edit_link.present?
            end

            def has_delete_link?
              delete_link.present?
            end
          RUBY
        end

        validations.join("\n\n    ")
      end

      def generate_helper_methods(route, options)
        <<~RUBY
          def wait_for_page_load
            # Wait for specific elements or conditions
            page.has_css?('body')
          end

          def current_path_matches?
            current_path == self.class.path
          end
        RUBY
      end

      def pom_class_name(controller, action)
        "#{controller.camelize}#{action.camelize}Page"
      end

      def pom_file_path(controller, action)
        filename = "#{controller}_#{action}_page.rb"
        File.join(RailsRouteTester.configuration.pom_base_path, filename)
      end

      def path_helper_method(route)
        if route[:name] && !route[:name].empty?
          "#{route[:name]}_path"
        else
          "'/#{route[:path].gsub(/\(\.:format\)$/, '')}'"
        end
      end

      def url_helper_method(route)
        if route[:name] && !route[:name].empty?
          "#{route[:name]}_url"
        else
          "root_url + '#{route[:path].gsub(/\(\.:format\)$/, '')}'"
        end
      end

      def base_pom_content
        <<~RUBY
          require 'capybara/dsl'

          # Base Page Object Model class
          # All page objects should inherit from this class
          class BasePage
            include Capybara::DSL

            # Class methods for defining page elements
            def self.element(name, selector, options = {})
              define_method(name) do
                find(selector, options)
              end

              define_method("\#{name}?") do
                has_css?(selector, options)
              end
            end

            def self.elements(name, selector, options = {})
              define_method(name) do
                all(selector, options)
              end

              define_method("has_\#{name}?") do
                has_css?(selector, options)
              end
            end

            # Instance methods available to all pages
            def initialize
              # Override in subclasses if needed
            end

            def visit_page
              visit(self.class.path)
              wait_for_page_load
              self
            end

            def current_page?
              current_path == self.class.path
            end

            def wait_for_page_load
              # Override in subclasses for specific loading conditions
              page.has_css?('body')
            end

            def take_screenshot(name = nil)
              name ||= "\#{self.class.name.underscore}_\#{Time.current.to_i}"
              page.save_screenshot("tmp/screenshots/\#{name}.png")
            end

            # Common page interactions
            def click_link(text)
              click_link(text)
            end

            def click_button(text)
              click_button(text)
            end

            def fill_in_field(field, value)
              fill_in(field, with: value)
            end

            def select_option(field, option)
              select(option, from: field)
            end

            # Common validations
            def has_text?(text)
              page.has_text?(text)
            end

            def has_link?(text)
              page.has_link?(text)
            end

            def has_button?(text)
              page.has_button?(text)
            end

            def has_field?(field)
              page.has_field?(field)
            end
          end
        RUBY
      end

      def ensure_directory_exists(directory)
        FileUtils.mkdir_p(directory) unless File.directory?(directory)
      end
    end
  end
end

