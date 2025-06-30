require "fileutils"

module RailsRouteTester
  module Generators
    class RspecGenerator
      attr_reader :route_analyzer, :pom_generator

      def initialize
        @route_analyzer = RouteAnalyzer.new
        @pom_generator = PomGenerator.new
      end

      # Generate RSpec feature test for a specific route
      def generate_feature_test_for_route(controller, action, options = {})
        route = find_route(controller, action)
        return false unless route

        # Ensure POM exists
        pom_path = @pom_generator.generate_pom_for_route(controller, action, options)
        
        test_content = build_rspec_content(route, options)
        test_path = rspec_file_path(controller, action)
        
        ensure_directory_exists(File.dirname(test_path))
        File.write(test_path, test_content)
        
        test_path
      end

      # Generate RSpec feature tests for all routes
      def generate_all_feature_tests(options = {})
        generated_files = []
        
        @route_analyzer.list_routes.each do |route|
          begin
            file_path = generate_feature_test_for_route(route[:controller], route[:action], options)
            generated_files << file_path if file_path
          rescue => e
            puts "Error generating RSpec test for #{route[:controller]}##{route[:action]}: #{e.message}"
          end
        end
        
        generated_files
      end

      # Generate RSpec configuration and support files
      def generate_support_files
        files = []
        
        # Generate spec_helper if it doesn't exist
        spec_helper_path = "spec/spec_helper.rb"
        unless File.exist?(spec_helper_path)
          ensure_directory_exists(File.dirname(spec_helper_path))
          File.write(spec_helper_path, spec_helper_content)
          files << spec_helper_path
        end

        # Generate rails_helper if it doesn't exist
        rails_helper_path = "spec/rails_helper.rb"
        unless File.exist?(rails_helper_path)
          ensure_directory_exists(File.dirname(rails_helper_path))
          File.write(rails_helper_path, rails_helper_content)
          files << rails_helper_path
        end

        # Generate feature helper
        feature_helper_path = "spec/support/feature_helper.rb"
        ensure_directory_exists(File.dirname(feature_helper_path))
        File.write(feature_helper_path, feature_helper_content)
        files << feature_helper_path

        files
      end

      private

      def find_route(controller, action)
        @route_analyzer.list_routes.find do |route|
          route[:controller] == controller && route[:action] == action
        end
      end

      def build_rspec_content(route, options = {})
        pom_class_name = "#{route[:controller].camelize}#{route[:action].camelize}Page"
        pom_file_name = "#{route[:controller]}_#{route[:action]}_page"
        
        template = <<~RUBY
          require 'rails_helper'
          require_relative '../support/page_objects/#{pom_file_name}'

          RSpec.describe "#{route[:controller].humanize} #{route[:action].humanize}", type: :feature do
            let(:page_object) { #{pom_class_name}.new }

            #{generate_setup_blocks(route, options)}

            #{generate_test_scenarios(route, options)}

            #{generate_shared_examples(route, options)}
          end
        RUBY

        template
      end

      def generate_setup_blocks(route, options)
        setup_blocks = []

        # Common setup
        setup_blocks << <<~RUBY
          before(:each) do
            # Setup test data and authentication if needed
            # Example: sign_in create(:user) if authentication required
          end

          after(:each) do
            # Cleanup after each test
            # Example: Capybara.reset_sessions!
          end
        RUBY

        # Action-specific setup
        case route[:action]
        when 'show', 'edit', 'update', 'destroy'
          setup_blocks << <<~RUBY
            let(:#{route[:controller].singularize}) { create(:#{route[:controller].singularize}) }
          RUBY
        end

        setup_blocks.join("\n\n  ")
      end

      def generate_test_scenarios(route, options)
        scenarios = []

        case route[:action]
        when 'index'
          scenarios << generate_index_scenarios(route)
        when 'show'
          scenarios << generate_show_scenarios(route)
        when 'new'
          scenarios << generate_new_scenarios(route)
        when 'create'
          scenarios << generate_create_scenarios(route)
        when 'edit'
          scenarios << generate_edit_scenarios(route)
        when 'update'
          scenarios << generate_update_scenarios(route)
        when 'destroy'
          scenarios << generate_destroy_scenarios(route)
        else
          scenarios << generate_generic_scenarios(route)
        end

        scenarios.join("\n\n  ")
      end

      def generate_index_scenarios(route)
        <<~RUBY
          describe "visiting the #{route[:controller]} index page" do
            context "when there are no #{route[:controller]}" do
              it "displays an empty state message" do
                page_object.visit_page
                capture_test_step("after_visit_page")
                
                expect(page_object).to be_loaded
                capture_test_step("after_loaded_check")
                expect(page_object).to have_correct_title
                capture_test_step("after_title_check")
                # Add specific assertions for empty state
              end
            end

            context "when there are #{route[:controller]}" do
              before do
                create_list(:#{route[:controller].singularize}, 3)
              end

              it "displays the list of #{route[:controller]}" do
                page_object.visit_page
                capture_test_step("after_visit_page")
                
                expect(page_object).to be_loaded
                capture_test_step("after_loaded_check")
                expect(page_object).to have_items
                capture_test_step("after_items_check")
                expect(page_object.list_items.count).to eq(3)
                capture_test_step("after_count_check")
              end

              it "allows searching through #{route[:controller]}" do
                searchable_item = create(:#{route[:controller].singularize}, name: "Searchable Item")
                page_object.visit_page
                capture_test_step("after_visit_page")
                
                page_object.search_for("Searchable")
                capture_test_step("after_search")
                
                expect(page_object).to have_text("Searchable Item")
                capture_test_step("after_search_verification")
              end
            end
          end
        RUBY
      end

      def generate_show_scenarios(route)
        <<~RUBY
          describe "viewing a #{route[:controller].singularize}" do
            it "displays the #{route[:controller].singularize} details" do
              page_object.visit_page
              capture_test_step("after_visit_page")
              
              expect(page_object).to be_loaded
              capture_test_step("after_loaded_check")
              expect(page_object).to have_correct_title
              capture_test_step("after_title_check")
              # Add specific assertions for #{route[:controller].singularize} details
            end

            it "shows all required #{route[:controller].singularize} information" do
              page_object.visit_page
              capture_test_step("after_visit_page")
              
              # Add specific assertions for #{route[:controller].singularize} information
              expect(page_object).to have_content(#{route[:controller].singularize}.name)
              capture_test_step("after_content_check")
            end
          end
        RUBY
      end

      def generate_new_scenarios(route)
        <<~RUBY
          describe "accessing the new #{route[:controller].singularize} form" do
            it "displays the form correctly" do
              page_object.visit_page
              capture_test_step("after_visit_page")
              
              expect(page_object).to be_loaded
              capture_test_step("after_loaded_check")
              expect(page_object).to have_form
              capture_test_step("after_form_check")
              # Add specific form field assertions
            end

            it "shows all required form fields" do
              page_object.visit_page
              capture_test_step("after_visit_page")
              
              # Add specific field assertions
              expect(page_object).to have_submit_button
              capture_test_step("after_fields_check")
            end
          end
        RUBY
      end

      def generate_create_scenarios(route)
        <<~RUBY
          describe "creating a new #{route[:controller].singularize}" do
            it "successfully creates a #{route[:controller].singularize} with valid data" do
              page_object.visit_page
              capture_test_step("after_visit_page")
              
              expect {
                page_object.fill_form_with_valid_data
                capture_test_step("after_fill_form")
                page_object.submit_form
                capture_test_step("after_submit_form")
              }.to change(#{route[:controller].singularize.camelize}, :count).by(1)
              
              expect(page_object).to have_flash_message(:success)
              capture_test_step("after_success_check")
            end

            it "shows validation errors with invalid data" do
              page_object.visit_page
              capture_test_step("after_visit_page")
              
              page_object.fill_form_with_invalid_data
              capture_test_step("after_fill_invalid_form")
              page_object.submit_form
              capture_test_step("after_submit_invalid_form")
              
              expect(page_object).to have_validation_errors
              capture_test_step("after_validation_check")
            end
          end
        RUBY
      end

      def generate_edit_scenarios(route)
        <<~RUBY
          describe "editing a #{route[:controller].singularize}" do
            it "displays the edit form with current data" do
              page_object.visit_page
              capture_test_step("after_visit_page")
              
              expect(page_object).to be_loaded
              capture_test_step("after_loaded_check")
              expect(page_object).to have_form
              capture_test_step("after_form_check")
              expect(page_object).to have_prefilled_data
              capture_test_step("after_prefilled_check")
            end

            it "allows canceling the edit" do
              page_object.visit_page
              capture_test_step("after_visit_page")
              
              page_object.cancel
              capture_test_step("after_cancel")
              
              # Assert navigation back to appropriate page
              expect(current_path).not_to eq(page_object.class.path)
            end
          end
        RUBY
      end

      def generate_update_scenarios(route)
        <<~RUBY
          describe "updating a #{route[:controller].singularize}" do
            it "successfully updates with valid data" do
              original_name = #{route[:controller].singularize}.name
              page_object.visit_page
              capture_test_step("after_visit_page")
              
              page_object.fill_form_with_valid_data
              capture_test_step("after_fill_form")
              page_object.submit_form
              capture_test_step("after_submit_form")
              
              expect(page_object).to have_flash_message(:success)
              capture_test_step("after_success_check")
              expect(#{route[:controller].singularize}.reload.name).not_to eq(original_name)
              capture_test_step("after_update_verification")
            end

            it "shows validation errors with invalid data" do
              page_object.visit_page
              capture_test_step("after_visit_page")
              
              page_object.fill_form_with_invalid_data
              capture_test_step("after_fill_invalid_form")
              page_object.submit_form
              capture_test_step("after_submit_invalid_form")
              
              expect(page_object).to have_validation_errors
              capture_test_step("after_validation_check")
            end
          end
        RUBY
      end

      def generate_destroy_scenarios(route)
        <<~RUBY
          describe "deleting a #{route[:controller].singularize}" do
            it "successfully deletes the #{route[:controller].singularize}" do
              page_object.visit_page
              capture_test_step("after_visit_page")
              
              expect {
                page_object.confirm_delete
                capture_test_step("after_confirm_delete")
              }.to change(#{route[:controller].singularize.camelize}, :count).by(-1)
              
              expect(page_object).to have_flash_message(:success)
              capture_test_step("after_success_check")
            end

            it "allows canceling the deletion" do
              page_object.visit_page
              capture_test_step("after_visit_page")
              
              page_object.cancel_delete
              capture_test_step("after_cancel_delete")
              
              expect(#{route[:controller].singularize.camelize}.count).to eq(1)
              capture_test_step("after_cancel_verification")
            end
          end
        RUBY
      end

      def generate_generic_scenarios(route)
        <<~RUBY
          describe "#{route[:action]} action" do
            it "loads the page successfully" do
              page_object.visit_page
              capture_test_step("after_visit_page")
              
              expect(page_object).to be_loaded
              capture_test_step("after_loaded_check")
              expect(page_object).to have_correct_title
              capture_test_step("after_title_check")
            end

            it "displays the correct content" do
              page_object.visit_page
              capture_test_step("after_visit_page")
              
              # Add specific assertions for this action
              expect(page).to have_content("#{route[:controller].humanize}")
              capture_test_step("after_content_check")
            end

            it "maintains proper navigation" do
              page_object.visit_page
              capture_test_step("after_visit_page")
              
              expect(page_object.navigation).to be_present
              capture_test_step("after_navigation_check")
            end
          end
        RUBY
      end

      def generate_shared_examples(route, options)
        <<~RUBY
          shared_examples "a properly rendered page" do
            it "has the correct page title" do
              expect(page_object).to have_correct_title
            end

            it "loads without errors" do
              expect(page_object).to be_loaded
              expect(page).not_to have_content("Error")
            end

            it "has proper navigation" do
              expect(page_object.navigation).to be_present
            end
          end

          describe "page rendering" do
            before { page_object.visit_page }
            it_behaves_like "a properly rendered page"
          end
        RUBY
      end

      def rspec_file_path(controller, action)
        filename = "#{controller}_#{action}_spec.rb"
        File.join(RailsRouteTester.configuration.spec_base_path, filename)
      end

      def spec_helper_content
        <<~RUBY
          require 'capybara/rspec'
          require 'capybara/rails'

          RSpec.configure do |config|
            config.expect_with :rspec do |expectations|
              expectations.include_chain_clauses_in_custom_matcher_descriptions = true
            end

            config.mock_with :rspec do |mocks|
              mocks.verify_partial_doubles = true
            end

            config.shared_context_metadata_behavior = :apply_to_host_groups
            config.filter_run_when_matching :focus
            config.example_status_persistence_file_path = "spec/examples.txt"
            config.disable_monkey_patching!
            config.warnings = true

            if config.files_to_run.one?
              config.default_formatter = "doc"
            end

            config.profile_examples = 10
            config.order = :random
            Kernel.srand config.seed
          end
        RUBY
      end

      def rails_helper_content
        <<~RUBY
          require 'spec_helper'
          ENV['RAILS_ENV'] ||= 'test'
          require File.expand_path('../config/environment', __dir__)
          abort("The Rails environment is running in production mode!") if Rails.env.production?
          require 'rspec/rails'
          require 'capybara/rails'
          require 'capybara/rspec'

          # Requires supporting ruby files with custom matchers and macros, etc,
          # in spec/support/ and its subdirectories.
          Dir[Rails.root.join('spec', 'support', '**', '*.rb')].sort.each { |f| require f }

          begin
            ActiveRecord::Migration.maintain_test_schema!
          rescue ActiveRecord::PendingMigrationError => e
            puts e.to_s.strip
            exit 1
          end

          RSpec.configure do |config|
            config.fixture_path = "\#{::Rails.root}/spec/fixtures"
            config.use_transactional_fixtures = true
            config.infer_spec_type_from_file_location!
            config.filter_rails_from_backtrace!

            # Include FactoryBot methods
            config.include FactoryBot::Syntax::Methods if defined?(FactoryBot)

            # Capybara configuration
            Capybara.default_driver = :rack_test
            Capybara.javascript_driver = :selenium_chrome_headless

            # Screenshot configuration
            config.after(:each, :screenshot) do |example|
              if example.exception
                meta = example.metadata
                filename = File.basename(meta[:file_path])
                line_number = meta[:line_number]
                screenshot_name = "\#{filename}-\#{line_number}-\#{Time.current.to_i}"
                page.save_screenshot("tmp/screenshots/\#{screenshot_name}.png")
              end
            end
          end
        RUBY
      end

      def feature_helper_content
        <<~RUBY
          # Feature test helper methods and configurations
          require 'rails_route_tester/test_capture_helper'

          module FeatureHelper
            def sign_in_user(user = nil)
              user ||= create(:user)
              # Implement your authentication logic here
              # Example for Devise:
              # login_as(user, scope: :user)
              user
            end

            def sign_out_user
              # Implement your sign out logic here
              # Example for Devise:
              # logout(:user)
            end

            def wait_for_ajax
              Timeout.timeout(Capybara.default_max_wait_time) do
                loop until finished_all_ajax_requests?
              end
            end

            def finished_all_ajax_requests?
              page.evaluate_script('jQuery.active').zero?
            rescue
              true
            end

            def accept_confirm_dialog
              page.driver.browser.switch_to.alert.accept
            rescue
              # No dialog present
            end

            def dismiss_confirm_dialog
              page.driver.browser.switch_to.alert.dismiss
            rescue
              # No dialog present
            end

            # Test capture methods
            def capture_test_step(step_name = nil)
              example_name = RSpec.current_example&.full_description || "unknown_test"
              RailsRouteTester::TestCaptureHelper.capture_test_results(example_name, step_name)
            end

            def capture_after_each_step
              example_name = RSpec.current_example&.full_description || "unknown_test"
              RailsRouteTester::TestCaptureHelper.capture_test_results(example_name, "after_step")
            end
          end

          RSpec.configure do |config|
            config.include FeatureHelper, type: :feature

            # Capture test results after each step
            config.after(:each, type: :feature) do |example|
              if example.exception
                # Capture on failure
                capture_test_step("failure")
              else
                # Capture on success
                capture_test_step("success")
              end
            end

            # Capture test results before each step (for debugging)
            config.before(:each, type: :feature) do |example|
              # Only capture if explicitly requested via metadata
              if example.metadata[:capture_steps]
                capture_test_step("before_step")
              end
            end

            # Cleanup old test results (keep last 7 days)
            config.after(:suite) do
              RailsRouteTester::TestCaptureHelper.cleanup_old_results(7)
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

