# Rails Route Tester - Usage Examples

This document provides practical examples of how to use the Rails Route Tester gem in real-world scenarios.

## Example 1: Setting Up Testing for a New Rails Application

Let's say you have a Rails application with a `User` model and controller with standard CRUD operations.

### Step 1: Install and Configure

Add to your Gemfile:
```ruby
gem 'rails_route_tester', group: [:development, :test]
```

Create an initializer:
```ruby
# config/initializers/rails_route_tester.rb
RailsRouteTester.configure do |config|
  config.pom_base_path = "spec/support/page_objects"
  config.spec_base_path = "spec/features"
  config.features_base_path = "features"
end
```

### Step 2: Analyze Your Routes

```bash
$ rake routes:list

================================================================================
RAILS ROUTES ANALYSIS
================================================================================
NAME             METHOD   PATH                     CONTROLLER#ACTION
--------------------------------------------------------------------------------
users            GET      /users                   users#index
user             GET      /users/:id               users#show
new_user         GET      /users/new               users#new
                 POST     /users                   users#create
edit_user        GET      /users/:id/edit          users#edit
                 PATCH    /users/:id               users#update
                 DELETE   /users/:id               users#destroy

Total routes: 7
```

### Step 3: Check Current Test Coverage

```bash
$ rake routes:coverage

============================================================
TEST COVERAGE STATISTICS
============================================================
Total routes: 7

RSpec Coverage:
  Routes with RSpec tests: 0
  Coverage percentage: 0.0%

Cucumber Coverage:
  Routes with Cucumber tests: 0
  Coverage percentage: 0.0%

Overall Coverage:
  Routes with any tests: 0
  Coverage percentage: 0.0%

Recommendations:
- Run 'rake routes:without_tests' to see untested routes
- Run 'rake tests:generate:all' to generate tests for all routes
- Run 'rake pom:generate:all' to generate Page Object Models
```

### Step 4: Generate Complete Test Suite

```bash
$ rake tests:generate:all

Generating comprehensive test suite for all routes...
======================================================================
Step 1: Generating Page Object Models...
Base POM: spec/support/page_objects/base_page.rb
Generated 7 Page Object Models:
  - spec/support/page_objects/users_index_page.rb
  - spec/support/page_objects/users_show_page.rb
  - spec/support/page_objects/users_new_page.rb
  - spec/support/page_objects/users_create_page.rb
  - spec/support/page_objects/users_edit_page.rb
  - spec/support/page_objects/users_update_page.rb
  - spec/support/page_objects/users_destroy_page.rb

======================================================================
Step 2: Generating RSpec feature tests...
Support files:
  - spec/spec_helper.rb
  - spec/rails_helper.rb
  - spec/support/feature_helper.rb

Generated 7 RSpec feature tests:
  - spec/features/users_index_spec.rb
  - spec/features/users_show_spec.rb
  - spec/features/users_new_spec.rb
  - spec/features/users_create_spec.rb
  - spec/features/users_edit_spec.rb
  - spec/features/users_update_spec.rb
  - spec/features/users_destroy_spec.rb

======================================================================
Step 3: Generating Cucumber feature tests...
Support files:
  - cucumber.yml
  - features/support/env.rb
  - features/support/world_extensions.rb
  - features/step_definitions/common_steps.rb

Generated 14 Cucumber files:
  - features/users_index.feature
  - features/step_definitions/users_index_steps.rb
  - features/users_show.feature
  - features/step_definitions/users_show_steps.rb
  - features/users_new.feature
  - features/step_definitions/users_new_steps.rb
  - features/users_create.feature
  - features/step_definitions/users_create_steps.rb
  - features/users_edit.feature
  - features/step_definitions/users_edit_steps.rb
  - features/users_update.feature
  - features/step_definitions/users_update_steps.rb
  - features/users_destroy.feature
  - features/step_definitions/users_destroy_steps.rb

======================================================================
TEST SUITE GENERATION COMPLETE!
======================================================================

Your Rails application now has:
✓ Page Object Models for all routes
✓ RSpec feature tests with POM integration
✓ Cucumber feature tests with step definitions
✓ Support files and configuration
```

## Example 2: Adding Tests for a Single New Route

Let's say you've added a new `profile` action to your `UsersController`.

### Step 1: Check What's Missing

```bash
$ rake routes:without_tests

================================================================================
ROUTES WITHOUT TESTS
================================================================================
GET      /users/:id/profile               users#profile

Total routes without tests: 1

To generate tests for these routes, run:
  rake tests:generate:all
```

### Step 2: Generate Tests for the Specific Route

```bash
$ rake tests:generate:both[users,profile]

Generating both RSpec and Cucumber tests for users#profile...
======================================================================
RSpec feature test generated successfully!
File: spec/features/users_profile_spec.rb

The test includes:
- Page Object Model integration
- Action-specific test scenarios
- Shared examples for common validations
- Screenshot capabilities

To run the test:
  rspec spec/features/users_profile_spec.rb

----------------------------------------

Cucumber feature test generated successfully!
Files:
  - features/users_profile.feature
  - features/step_definitions/users_profile_steps.rb

The test includes:
- Gherkin feature scenarios
- Step definitions with POM integration
- Background setup and data management
- Action-specific test scenarios

To run the test:
  cucumber features/users_profile.feature
```

## Example 3: Customizing Generated Page Object Models

After generation, you'll want to customize the POMs to match your actual application.

### Original Generated POM

```ruby
# spec/support/page_objects/users_index_page.rb
class UsersIndexPage < BasePage
  def self.path
    users_path
  end

  def self.url
    users_url
  end

  # Page elements - customize these based on your actual page structure
  element :search_field, 'input[type="search"]'
  element :filter_dropdown, 'select.filter'
  elements :list_items, '.list-item'
  element :pagination, '.pagination'
  element :navigation, 'nav'
  element :flash_messages, '.flash, .alert, .notice'

  # Page actions - customize these based on your page functionality
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
end
```

### Customized POM for Your Application

```ruby
# spec/support/page_objects/users_index_page.rb
class UsersIndexPage < BasePage
  def self.path
    users_path
  end

  def self.url
    users_url
  end

  # Customized elements based on actual HTML structure
  element :search_input, '#user-search'
  element :role_filter, 'select[name="role"]'
  element :status_filter, 'select[name="status"]'
  elements :user_rows, 'tbody tr'
  element :new_user_button, '.btn-new-user'
  element :pagination_nav, '.pagination-wrapper'
  element :results_count, '.results-count'

  # Customized actions
  def search_for_user(name)
    search_input.set(name)
    search_input.send_keys(:return)
    wait_for_search_results
  end

  def filter_by_role(role)
    role_filter.select(role)
    wait_for_filter_results
  end

  def filter_by_status(status)
    status_filter.select(status)
    wait_for_filter_results
  end

  def click_user(name)
    user_row = user_rows.find { |row| row.text.include?(name) }
    user_row.find('a').click
  end

  def create_new_user
    new_user_button.click
  end

  # Custom validations
  def has_user?(name)
    user_rows.any? { |row| row.text.include?(name) }
  end

  def user_count
    user_rows.count
  end

  def results_text
    results_count.text
  end

  private

  def wait_for_search_results
    page.has_css?('.search-loading', visible: false)
  end

  def wait_for_filter_results
    page.has_css?('.filter-loading', visible: false)
  end
end
```

## Example 4: Running and Maintaining Tests

### Running Tests

```bash
# Run all RSpec feature tests
$ rake tests:run_rspec

# Run all Cucumber tests
$ rake tests:run_cucumber

# Run specific test
$ rspec spec/features/users_index_spec.rb
$ cucumber features/users_index.feature

# Run with specific tags
$ cucumber --tags @users
$ cucumber --tags @search
```

### Maintenance Tasks

```bash
# Check for unused test files after removing routes
$ rake tests:cleanup

# Validate all POMs are properly structured
$ rake pom:validate

# Clean up unused POMs
$ rake pom:cleanup

# Get updated coverage statistics
$ rake routes:coverage
```

## Example 5: Integration with FactoryBot

To make the generated tests work properly, you'll need FactoryBot factories:

```ruby
# spec/factories/users.rb
FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    sequence(:name) { |n| "User #{n}" }
    password { "password123" }
    role { "member" }
    status { "active" }

    trait :admin do
      role { "admin" }
    end

    trait :inactive do
      status { "inactive" }
    end

    trait :with_sample_data do
      name { "John Doe" }
      email { "john.doe@example.com" }
      bio { "Sample user for testing purposes" }
    end
  end
end
```

## Example 6: Continuous Integration Setup

Add to your CI configuration:

```yaml
# .github/workflows/test.yml
name: Test Suite

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v2
    
    - name: Set up Ruby
      uses: ruby/setup-ruby@v1
      with:
        ruby-version: 3.0
        bundler-cache: true
    
    - name: Setup Database
      run: |
        bundle exec rails db:create
        bundle exec rails db:migrate
    
    - name: Run RSpec tests
      run: bundle exec rake tests:run_rspec
    
    - name: Run Cucumber tests
      run: bundle exec rake tests:run_cucumber
    
    - name: Check test coverage
      run: bundle exec rake routes:coverage
```

## Example 7: Advanced Configuration

```ruby
# config/initializers/rails_route_tester.rb
RailsRouteTester.configure do |config|
  # Customize paths based on your project structure
  config.pom_base_path = "spec/support/page_objects"
  config.spec_base_path = "spec/features"
  config.features_base_path = "features"
  
  # Set default test framework
  config.test_framework = :rspec
end

# For projects using different directory structures
RailsRouteTester.configure do |config|
  config.pom_base_path = "test/page_objects"
  config.spec_base_path = "test/features"
  config.features_base_path = "test/cucumber"
end
```

These examples demonstrate the flexibility and power of the Rails Route Tester gem in various real-world scenarios. The gem adapts to your existing project structure while providing comprehensive testing capabilities.

