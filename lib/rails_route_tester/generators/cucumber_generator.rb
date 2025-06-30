require "fileutils"

module RailsRouteTester
  module Generators
    class CucumberGenerator
      attr_reader :route_analyzer, :pom_generator

      def initialize
        @route_analyzer = RouteAnalyzer.new
        @pom_generator = PomGenerator.new
      end

      # Generate Cucumber feature test for a specific route
      def generate_feature_test_for_route(controller, action, options = {})
        route = find_route(controller, action)
        return false unless route

        # Ensure POM exists
        pom_path = @pom_generator.generate_pom_for_route(controller, action, options)
        
        feature_content = build_feature_content(route, options)
        feature_path = feature_file_path(controller, action)
        
        ensure_directory_exists(File.dirname(feature_path))
        File.write(feature_path, feature_content)
        
        # Generate step definitions
        steps_content = build_step_definitions(route, options)
        steps_path = step_definitions_file_path(controller, action)
        
        ensure_directory_exists(File.dirname(steps_path))
        File.write(steps_path, steps_content)
        
        [feature_path, steps_path]
      end

      # Generate Cucumber feature tests for all routes
      def generate_all_feature_tests(options = {})
        generated_files = []
        
        @route_analyzer.list_routes.each do |route|
          begin
            files = generate_feature_test_for_route(route[:controller], route[:action], options)
            generated_files.concat(files) if files
          rescue => e
            puts "Error generating Cucumber test for #{route[:controller]}##{route[:action]}: #{e.message}"
          end
        end
        
        generated_files
      end

      # Generate Cucumber configuration and support files
      def generate_support_files
        files = []
        
        # Generate cucumber.yml
        cucumber_config_path = "cucumber.yml"
        unless File.exist?(cucumber_config_path)
          File.write(cucumber_config_path, cucumber_config_content)
          files << cucumber_config_path
        end

        # Generate env.rb
        env_path = "features/support/env.rb"
        ensure_directory_exists(File.dirname(env_path))
        File.write(env_path, env_content)
        files << env_path

        # Generate world extensions
        world_path = "features/support/world_extensions.rb"
        ensure_directory_exists(File.dirname(world_path))
        File.write(world_path, world_extensions_content)
        files << world_path

        # Generate common step definitions
        common_steps_path = "features/step_definitions/common_steps.rb"
        ensure_directory_exists(File.dirname(common_steps_path))
        File.write(common_steps_path, common_steps_content)
        files << common_steps_path

        files
      end

      private

      def find_route(controller, action)
        @route_analyzer.list_routes.find do |route|
          route[:controller] == controller && route[:action] == action
        end
      end

      def build_feature_content(route, options = {})
        feature_title = "#{route[:controller].humanize} #{route[:action].humanize}"
        
        template = <<~GHERKIN
          @#{route[:controller]} @#{route[:action]}
          Feature: #{feature_title}
            As a user
            I want to #{generate_user_story(route)}
            So that #{generate_user_benefit(route)}

            Background:
              Given I am on the application
              #{generate_background_steps(route)}

            #{generate_scenarios(route, options)}
        GHERKIN

        template
      end

      def generate_user_story(route)
        case route[:action]
        when 'index'
          "view all #{route[:controller]}"
        when 'show'
          "view a specific #{route[:controller].singularize}"
        when 'new'
          "access the form to create a new #{route[:controller].singularize}"
        when 'create'
          "create a new #{route[:controller].singularize}"
        when 'edit'
          "access the form to edit a #{route[:controller].singularize}"
        when 'update'
          "update an existing #{route[:controller].singularize}"
        when 'destroy'
          "delete a #{route[:controller].singularize}"
        else
          "interact with #{route[:controller]} #{route[:action]}"
        end
      end

      def generate_user_benefit(route)
        case route[:action]
        when 'index'
          "I can see all available #{route[:controller]} and navigate to specific ones"
        when 'show'
          "I can view detailed information about the #{route[:controller].singularize}"
        when 'new', 'create'
          "I can add new #{route[:controller]} to the system"
        when 'edit', 'update'
          "I can modify existing #{route[:controller]} information"
        when 'destroy'
          "I can remove #{route[:controller]} that are no longer needed"
        else
          "I can accomplish my goals related to #{route[:controller]}"
        end
      end

      def generate_background_steps(route)
        steps = []
        
        # Add authentication if needed
        steps << "And I am authenticated as a user" if requires_authentication?(route)
        
        # Add test data setup for show/edit/update/destroy actions
        if %w[show edit update destroy].include?(route[:action])
          steps << "And there is a #{route[:controller].singularize} in the system"
        end

        steps.join("\n    ")
      end

      def generate_scenarios(route, options)
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
        <<~GHERKIN
          Scenario: Viewing empty #{route[:controller]} list
            Given there are no #{route[:controller]} in the system
            When I visit the #{route[:controller]} index page
            Then I should see an empty state message
            And I should see a link to create a new #{route[:controller].singularize}

          Scenario: Viewing #{route[:controller]} list with items
            Given there are 3 #{route[:controller]} in the system
            When I visit the #{route[:controller]} index page
            Then I should see 3 #{route[:controller]} listed
            And each #{route[:controller].singularize} should display its basic information

          @search
          Scenario: Searching #{route[:controller]}
            Given there are #{route[:controller]} with names "Alpha", "Beta", "Gamma"
            When I visit the #{route[:controller]} index page
            And I search for "Alpha"
            Then I should see only the "Alpha" #{route[:controller].singularize}
            And I should not see "Beta" or "Gamma"

          @pagination
          Scenario: Paginating through #{route[:controller]}
            Given there are 25 #{route[:controller]} in the system
            When I visit the #{route[:controller]} index page
            Then I should see pagination controls
            And I should see the first page of results
        GHERKIN
      end

      def generate_show_scenarios(route)
        <<~GHERKIN
          Scenario: Viewing #{route[:controller].singularize} details
            Given there is a #{route[:controller].singularize} named "Test Item"
            When I visit the #{route[:controller].singularize} show page
            Then I should see the #{route[:controller].singularize} details
            And I should see "Test Item" in the title
            And I should see edit and delete options

          Scenario: Navigating from #{route[:controller].singularize} details
            Given there is a #{route[:controller].singularize} in the system
            When I visit the #{route[:controller].singularize} show page
            And I click the edit link
            Then I should be on the edit #{route[:controller].singularize} page

          @screenshot
          Scenario: Taking screenshot of #{route[:controller].singularize} page
            Given there is a #{route[:controller].singularize} with sample data
            When I visit the #{route[:controller].singularize} show page
            Then I take a screenshot for documentation
        GHERKIN
      end

      def generate_new_scenarios(route)
        <<~GHERKIN
          Scenario: Accessing new #{route[:controller].singularize} form
            When I visit the new #{route[:controller].singularize} page
            Then I should see the #{route[:controller].singularize} creation form
            And all required fields should be present
            And I should see submit and cancel buttons

          Scenario: Canceling #{route[:controller].singularize} creation
            When I visit the new #{route[:controller].singularize} page
            And I click the cancel button
            Then I should be redirected to the #{route[:controller]} index page
            And no new #{route[:controller].singularize} should be created
        GHERKIN
      end

      def generate_create_scenarios(route)
        <<~GHERKIN
          Scenario: Successfully creating a #{route[:controller].singularize}
            When I visit the new #{route[:controller].singularize} page
            And I fill in the #{route[:controller].singularize} form with valid data
            And I submit the form
            Then I should see a success message
            And I should be on the #{route[:controller].singularize} show page
            And the #{route[:controller].singularize} should be saved in the system

          Scenario: Creating a #{route[:controller].singularize} with invalid data
            When I visit the new #{route[:controller].singularize} page
            And I fill in the #{route[:controller].singularize} form with invalid data
            And I submit the form
            Then I should see validation error messages
            And I should remain on the new #{route[:controller].singularize} page
            And no #{route[:controller].singularize} should be created

          Scenario: Creating a #{route[:controller].singularize} with missing required fields
            When I visit the new #{route[:controller].singularize} page
            And I submit the form without filling required fields
            Then I should see "can't be blank" error messages
            And the form should retain any entered data
        GHERKIN
      end

      def generate_edit_scenarios(route)
        <<~GHERKIN
          Scenario: Accessing edit #{route[:controller].singularize} form
            Given there is a #{route[:controller].singularize} named "Original Name"
            When I visit the edit #{route[:controller].singularize} page
            Then I should see the #{route[:controller].singularize} edit form
            And the form should be pre-filled with current values
            And I should see "Original Name" in the name field

          Scenario: Canceling #{route[:controller].singularize} edit
            Given there is a #{route[:controller].singularize} in the system
            When I visit the edit #{route[:controller].singularize} page
            And I click the cancel button
            Then I should be redirected to the #{route[:controller].singularize} show page
            And the #{route[:controller].singularize} should remain unchanged
        GHERKIN
      end

      def generate_update_scenarios(route)
        <<~GHERKIN
          Scenario: Successfully updating a #{route[:controller].singularize}
            Given there is a #{route[:controller].singularize} named "Original Name"
            When I visit the edit #{route[:controller].singularize} page
            And I change the name to "Updated Name"
            And I submit the form
            Then I should see a success message
            And I should be on the #{route[:controller].singularize} show page
            And I should see "Updated Name" in the title

          Scenario: Updating a #{route[:controller].singularize} with invalid data
            Given there is a #{route[:controller].singularize} in the system
            When I visit the edit #{route[:controller].singularize} page
            And I clear the name field
            And I submit the form
            Then I should see validation error messages
            And I should remain on the edit #{route[:controller].singularize} page
        GHERKIN
      end

      def generate_destroy_scenarios(route)
        <<~GHERKIN
          Scenario: Successfully deleting a #{route[:controller].singularize}
            Given there is a #{route[:controller].singularize} named "To Be Deleted"
            When I visit the #{route[:controller].singularize} show page
            And I click the delete button
            And I confirm the deletion
            Then I should see a success message
            And I should be on the #{route[:controller]} index page
            And "To Be Deleted" should no longer exist

          Scenario: Canceling #{route[:controller].singularize} deletion
            Given there is a #{route[:controller].singularize} in the system
            When I visit the #{route[:controller].singularize} show page
            And I click the delete button
            And I cancel the deletion
            Then I should remain on the #{route[:controller].singularize} show page
            And the #{route[:controller].singularize} should still exist
        GHERKIN
      end

      def generate_generic_scenarios(route)
        <<~GHERKIN
          Scenario: Accessing #{route[:action]} page
            When I visit the #{route[:controller]} #{route[:action]} page
            Then I should see the #{route[:action]} content
            And the page should load without errors

          Scenario: Page navigation and layout
            When I visit the #{route[:controller]} #{route[:action]} page
            Then I should see the main navigation
            And I should see the page title
            And the page should be properly formatted
        GHERKIN
      end

      def build_step_definitions(route, options = {})
        pom_class_name = "#{route[:controller].camelize}#{route[:action].camelize}Page"
        pom_file_name = "#{route[:controller]}_#{route[:action]}_page"
        
        template = <<~RUBY
          require_relative '../support/page_objects/#{pom_file_name}'

          # Step definitions for #{route[:controller]}##{route[:action]}
          
          #{generate_navigation_steps(route)}

          #{generate_interaction_steps(route)}

          #{generate_verification_steps(route)}

          #{generate_data_steps(route)}
        RUBY

        template
      end

      def generate_navigation_steps(route)
        pom_class_name = "#{route[:controller].camelize}#{route[:action].camelize}Page"
        
        <<~RUBY
          # Navigation steps for #{route[:controller]} #{route[:action]}
          Given("I visit the #{route[:controller]} #{route[:action]} page") do
            @page_object = #{pom_class_name}.new
            @page_object.visit_page
            capture_cucumber_step("visit_#{route[:controller]}_#{route[:action]}")
          end

          When("I navigate to the #{route[:controller]} #{route[:action]} page") do
            @page_object = #{pom_class_name}.new
            @page_object.visit_page
            capture_cucumber_step("navigate_to_#{route[:controller]}_#{route[:action]}")
          end

          Then("I should be on the #{route[:controller]} #{route[:action]} page") do
            expect(@page_object).to be_loaded
            capture_cucumber_step("verify_#{route[:controller]}_#{route[:action]}_loaded")
          end
        RUBY
      end

      def generate_interaction_steps(route)
        steps = []
        
        case route[:action]
        when 'index'
          steps << <<~RUBY
            # Index page interactions
            When("I search for {string} in the #{route[:controller]} list") do |search_term|
              @page_object.search_for(search_term)
              capture_cucumber_step("search_#{route[:controller]}")
            end

            When("I click on the first #{route[:controller].singularize} in the list") do
              @page_object.click_item(0)
              capture_cucumber_step("click_first_#{route[:controller].singularize}")
            end

            When("I click on the new #{route[:controller].singularize} link") do
              @page_object.click_new_link
              capture_cucumber_step("click_new_#{route[:controller].singularize}_link")
            end
          RUBY
        when 'show'
          steps << <<~RUBY
            # Show page interactions
            When("I click the edit #{route[:controller].singularize} link") do
              @page_object.click_edit_link
              capture_cucumber_step("click_edit_#{route[:controller].singularize}_link")
            end

            When("I click the delete #{route[:controller].singularize} link") do
              @page_object.click_delete_link
              capture_cucumber_step("click_delete_#{route[:controller].singularize}_link")
            end

            When("I confirm the deletion") do
              accept_confirm_dialog
              capture_cucumber_step("confirm_deletion")
            end

            When("I cancel the deletion") do
              dismiss_confirm_dialog
              capture_cucumber_step("cancel_deletion")
            end
          RUBY
        when 'new', 'create'
          steps << <<~RUBY
            # New/Create page interactions
            When("I fill in the #{route[:controller].singularize} form with valid data") do
              @page_object.fill_form_with_valid_data
              capture_cucumber_step("fill_valid_#{route[:controller].singularize}_form")
            end

            When("I fill in the #{route[:controller].singularize} form with invalid data") do
              @page_object.fill_form_with_invalid_data
              capture_cucumber_step("fill_invalid_#{route[:controller].singularize}_form")
            end

            When("I submit the #{route[:controller].singularize} form") do
              @page_object.submit_form
              capture_cucumber_step("submit_#{route[:controller].singularize}_form")
            end

            When("I cancel the #{route[:controller].singularize} form") do
              @page_object.cancel
              capture_cucumber_step("cancel_#{route[:controller].singularize}_form")
            end
          RUBY
        when 'edit', 'update'
          steps << <<~RUBY
            # Edit/Update page interactions
            When("I update the #{route[:controller].singularize} with valid data") do
              @page_object.fill_form_with_valid_data
              capture_cucumber_step("fill_valid_update_#{route[:controller].singularize}_form")
              @page_object.submit_form
              capture_cucumber_step("submit_update_#{route[:controller].singularize}_form")
            end

            When("I update the #{route[:controller].singularize} with invalid data") do
              @page_object.fill_form_with_invalid_data
              capture_cucumber_step("fill_invalid_update_#{route[:controller].singularize}_form")
              @page_object.submit_form
              capture_cucumber_step("submit_invalid_update_#{route[:controller].singularize}_form")
            end

            When("I cancel the #{route[:controller].singularize} update") do
              @page_object.cancel
              capture_cucumber_step("cancel_update_#{route[:controller].singularize}")
            end
          RUBY
        end

        steps.join("\n\n")
      end

      def generate_verification_steps(route)
        <<~RUBY
          # Verification steps for #{route[:controller]} #{route[:action]}
          Then("I should see the #{route[:controller]} #{route[:action]} page") do
            expect(@page_object).to be_loaded
            capture_cucumber_step("verify_#{route[:controller]}_#{route[:action]}_page_loaded")
          end

          Then("I should see the correct page title") do
            expect(@page_object).to have_correct_title
            capture_cucumber_step("verify_page_title")
          end

          Then("I should see a success message") do
            expect(@page_object).to have_flash_message(:success)
            capture_cucumber_step("verify_success_message")
          end

          Then("I should see an error message") do
            expect(@page_object).to have_flash_message(:error)
            capture_cucumber_step("verify_error_message")
          end

          Then("I should see validation errors") do
            expect(@page_object).to have_validation_errors
            capture_cucumber_step("verify_validation_errors")
          end

          Then("I should be redirected to the #{route[:controller]} index page") do
            expect(current_path).to eq(#{route[:controller]}_path)
            capture_cucumber_step("verify_redirect_to_#{route[:controller]}_index")
          end

          Then("I should be redirected to the #{route[:controller].singularize} show page") do
            expect(current_path).to eq(#{route[:controller].singularize}_path(#{route[:controller].singularize}))
            capture_cucumber_step("verify_redirect_to_#{route[:controller].singularize}_show")
          end
        RUBY
      end

      def generate_data_steps(route)
        <<~RUBY
          # Data setup steps
          Given(/^there (?:is|are) (?:a |)(\\d+) #{route[:controller]}(?: |)in the system$/) do |count|
            count.to_i.times do |i|
              create(:#{route[:controller].singularize}, name: "#{route[:controller].singularize.humanize} \#{i + 1}")
            end
          end

          Given(/^there (?:is|are) #{route[:controller]} with names "([^"]*)"$/) do |names|
            names.split('", "').each do |name|
              name = name.gsub(/^"|"$/, '') # Remove quotes
              create(:#{route[:controller].singularize}, name: name)
            end
          end

          Given(/^there is a #{route[:controller].singularize} named "([^"]*)"$/) do |name|
            @#{route[:controller].singularize} = create(:#{route[:controller].singularize}, name: name)
          end

          Given(/^there is a #{route[:controller].singularize} with sample data$/) do
            @#{route[:controller].singularize} = create(:#{route[:controller].singularize}, :with_sample_data)
          end

          Given(/^there are no #{route[:controller]} in the system$/) do
            #{route[:controller].singularize.camelize}.destroy_all
          end
        RUBY
      end

      def requires_authentication?(route)
        # This could be made configurable or smarter
        # For now, assume most actions require authentication except index and show
        !%w[index show].include?(route[:action])
      end

      def feature_file_path(controller, action)
        filename = "#{controller}_#{action}.feature"
        File.join(RailsRouteTester.configuration.features_base_path, filename)
      end

      def step_definitions_file_path(controller, action)
        filename = "#{controller}_#{action}_steps.rb"
        File.join(RailsRouteTester.configuration.features_base_path, "step_definitions", filename)
      end

      def cucumber_config_content
        <<~YAML
          default: --format pretty --strict --tags ~@wip
          wip: --tags @wip:3 --wip
          rerun: --format rerun --out rerun.txt --strict --tags ~@wip
          html: --format html --out features_report.html
          json: --format json --out cucumber.json
        YAML
      end

      def env_content
        <<~RUBY
          require 'cucumber/rails'
          require 'capybara/cucumber'
          require 'capybara/rspec'
          require 'factory_bot_rails'
          require 'rails_route_tester/test_capture_helper'

          # Capybara configuration
          Capybara.default_driver = :rack_test
          Capybara.javascript_driver = :selenium_chrome_headless
          Capybara.default_max_wait_time = 5

          # Database cleanup
          Before do
            DatabaseCleaner.start
          end

          After do |scenario|
            DatabaseCleaner.clean
            
            # Capture test results after each scenario
            if scenario.failed?
              capture_cucumber_step(scenario.name, "failure")
            else
              capture_cucumber_step(scenario.name, "success")
            end
          end

          # Capture test results after each step
          AfterStep do |scenario, step|
            capture_cucumber_step(scenario.name, step.name)
          end

          # Helper methods for test capture
          def capture_cucumber_step(scenario_name, step_name = nil)
            RailsRouteTester::TestCaptureHelper.capture_test_results(scenario_name, step_name)
          end

          # Cleanup old test results (keep last 7 days)
          at_exit do
            RailsRouteTester::TestCaptureHelper.cleanup_old_results(7)
          end

          # World extensions
          World(FactoryBot::Syntax::Methods) if defined?(FactoryBot)

          # Custom step definitions helpers
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
        RUBY
      end

      def world_extensions_content
        <<~RUBY
          module CucumberWorld
            def current_user
              @current_user
            end

            def sign_in_user(user = nil)
              @current_user = user || create(:user)
              # Implement your authentication logic here
              # Example for Devise:
              # login_as(@current_user, scope: :user)
              @current_user
            end

            def sign_out_user
              @current_user = nil
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
          end

          World(CucumberWorld)
        RUBY
      end

      def common_steps_content
        <<~RUBY
          # Common step definitions used across multiple features

          # Authentication steps
          Given(/^I am authenticated as a user$/) do
            sign_in_user
          end

          Given(/^I am on the application$/) do
            visit root_path
          end

          # Navigation steps
          When(/^I click the "([^"]*)" link$/) do |link_text|
            click_link(link_text)
          end

          When(/^I click the "([^"]*)" button$/) do |button_text|
            click_button(button_text)
          end

          # Form interaction steps
          When(/^I fill in "([^"]*)" with "([^"]*)"$/) do |field, value|
            fill_in(field, with: value)
          end

          When(/^I select "([^"]*)" from "([^"]*)"$/) do |value, field|
            select(value, from: field)
          end

          When(/^I check "([^"]*)"$/) do |field|
            check(field)
          end

          When(/^I uncheck "([^"]*)"$/) do |field|
            uncheck(field)
          end

          # Verification steps
          Then(/^I should see "([^"]*)"$/) do |text|
            expect(page).to have_content(text)
          end

          Then(/^I should not see "([^"]*)"$/) do |text|
            expect(page).not_to have_content(text)
          end

          Then(/^I should see the "([^"]*)" link$/) do |link_text|
            expect(page).to have_link(link_text)
          end

          Then(/^I should see the "([^"]*)" button$/) do |button_text|
            expect(page).to have_button(button_text)
          end

          Then(/^I should be on the "([^"]*)" page$/) do |page_name|
            case page_name.downcase
            when 'home', 'homepage'
              expect(current_path).to eq(root_path)
            else
              # Add more page mappings as needed
              expect(page).to have_content(page_name)
            end
          end

          # Wait steps
          When(/^I wait for (\\d+) seconds?$/) do |seconds|
            sleep(seconds.to_i)
          end

          When(/^I wait for the page to load$/) do
            expect(page).to have_css('body')
          end

          # Screenshot steps
          When(/^I take a screenshot$/) do
            page.save_screenshot("tmp/screenshots/step_\#{Time.current.to_i}.png")
          end
        RUBY
      end

      def ensure_directory_exists(directory)
        FileUtils.mkdir_p(directory) unless File.directory?(directory)
      end
    end
  end
end

