# Rails Route Tester

A comprehensive Ruby gem that provides Rake tasks for Rails applications to analyze routes, generate Page Object Models (POMs), and create RSpec/Cucumber tests with seamless integration.

## Features

- **Route Analysis**: List all routes and their associated test files
- **Page Object Model Generation**: Automatically generate POMs for each route
- **RSpec Integration**: Generate feature tests using POMs
- **Cucumber Integration**: Generate feature files and step definitions
- **Test Coverage Analysis**: Track which routes have tests
- **Bulk Operations**: Generate tests and POMs for all routes at once
- **Cleanup Tools**: Remove unused test files and POMs
- **Test Capture**: Automatically capture HTML and PNG files at every test step
- **Results Management**: Comprehensive tools for managing and viewing test results

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rails_route_tester'
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install rails_route_tester
```

## Quick Start

1. **List all routes in your application:**
   ```bash
   rake routes:list
   ```

2. **Generate Page Object Models for all routes:**
   ```bash
   rake pom:generate:all
   ```

3. **Generate comprehensive test suite:**
   ```bash
   rake tests:generate:all
   ```

4. **Check test coverage:**
   ```bash
   rake routes:coverage
   ```

## Configuration

Configure the gem in an initializer (`config/initializers/rails_route_tester.rb`):

```ruby
RailsRouteTester.configure do |config|
  config.pom_base_path = "spec/support/page_objects"
  config.spec_base_path = "spec/features"
  config.features_base_path = "features"
  config.test_framework = :rspec # or :cucumber
end
```

### Test Capture Configuration

The test capture functionality is automatically enabled for all generated tests. You can customize the behavior by adding these options to your test configuration:

```ruby
# In spec/rails_helper.rb or features/support/env.rb
RSpec.configure do |config|
  # Enable step-by-step capture for debugging (optional)
  config.before(:each, type: :feature, capture_steps: true) do |example|
    capture_test_step("before_step")
  end
end
```

For Cucumber, capture is automatically enabled for all steps. You can disable it for specific scenarios by adding a tag:

```gherkin
@no_capture
Scenario: This scenario won't capture results
  Given I visit the users index page
  Then I should see the users list
```

## Available Rake Tasks

### Route Analysis

```bash
# List all routes
rake routes:list

# Show routes with their associated tests
rake routes:with_tests

# Find routes without any tests
rake routes:without_tests

# Find routes without Page Object Models
rake routes:without_poms

# Show test coverage statistics
rake routes:coverage
```

### Page Object Model Management

```bash
# Generate POM for a specific route
rake pom:generate[controller,action]

# Generate POMs for all routes
rake pom:generate:all

# Generate POMs only for routes that don't have them
rake pom:generate:missing

# List all existing POMs
rake pom:list

# Validate existing POMs
rake pom:validate

# Clean up unused POMs
rake pom:cleanup
```

### Test Generation

```bash
# Generate RSpec test for a specific route
rake tests:generate:rspec[controller,action]

# Generate Cucumber test for a specific route
rake tests:generate:cucumber[controller,action]

# Generate both RSpec and Cucumber tests for a route
rake tests:generate:both[controller,action]

# Generate RSpec tests for all routes
rake tests:generate:rspec_all

# Generate Cucumber tests for all routes
rake tests:generate:cucumber_all

# Generate complete test suite (POMs + RSpec + Cucumber)
rake tests:generate:all
```

### Test Management

```bash
# List all existing test files
rake tests:list

# Run all RSpec feature tests
rake tests:run_rspec

# Run all Cucumber feature tests
rake tests:run_cucumber

# Run all tests
rake tests:run_all

# Clean up unused test files
rake tests:cleanup
```

### Test Results Management

```bash
# List all test result directories
rake results:list

# Show details for a specific test result
rake results:show[test_id]

# Generate test results summary report
rake results:report

# Open test results directory in file explorer
rake results:open

# Clean up old test results (default: 7 days)
rake results:cleanup[days]
```

## Test Capture and Results

The gem automatically captures HTML and PNG files at every test step, storing them in the `route_tests_results` directory. Each test execution creates a unique directory with:

- **HTML files**: Complete page HTML with metadata overlay
- **PNG screenshots**: Full-page screenshots at each step
- **Metadata files**: JSON files with test information, timestamps, and browser details

### Generated File Structure

```
route_tests_results/
├── test_name_20250101_120000_123/
│   ├── test_name_20250101_120000_123_after_visit_page.html
│   ├── test_name_20250101_120000_123_after_visit_page.png
│   ├── test_name_20250101_120000_123_after_loaded_check.html
│   ├── test_name_20250101_120000_123_after_loaded_check.png
│   ├── test_name_20250101_120000_123_metadata.json
│   └── ...
├── another_test_20250101_120100_456/
│   └── ...
└── ...
```

### Test Capture Features

- **Automatic capture**: HTML and PNG files captured at every test step
- **Metadata overlay**: HTML files include visible metadata overlay with test information
- **Timestamped directories**: Each test run gets a unique timestamped directory
- **Browser information**: Captures user agent, window size, and other browser details
- **Automatic cleanup**: Old test results automatically cleaned up after 7 days
- **Cross-platform**: Works on Windows, macOS, and Linux

## Generated File Structure

The gem creates the following file structure:

```
your_rails_app/
├── spec/
│   ├── features/
│   │   ├── users_index_spec.rb
│   │   ├── users_show_spec.rb
│   │   └── ...
│   ├── support/
│   │   ├── feature_helper.rb
│   │   └── page_objects/
│   │       ├── base_page.rb
│   │       ├── users_index_page.rb
│   │       ├── users_show_page.rb
│   │       └── ...
│   ├── spec_helper.rb
│   └── rails_helper.rb
├── features/
│   ├── users_index.feature
│   ├── users_show.feature
│   ├── step_definitions/
│   │   ├── common_steps.rb
│   │   ├── users_index_steps.rb
│   │   ├── users_show_steps.rb
│   │   └── ...
│   └── support/
│       ├── env.rb
│       └── world_extensions.rb
└── cucumber.yml
```

## Page Object Model Structure

Generated POMs follow a consistent structure:

```ruby
class UsersIndexPage < BasePage
  # URL helpers
  def self.path
    users_path
  end

  def self.url
    users_url
  end

  # Page elements
  element :search_field, 'input[type="search"]'
  elements :list_items, '.list-item'
  element :pagination, '.pagination'

  # Page actions
  def search_for(term)
    search_field.set(term)
    search_field.send_keys(:return)
  end

  def click_item(index = 0)
    list_items[index].click
  end

  # Validations
  def has_correct_title?
    page.has_css?('h1', text: /Users/i)
  end

  def has_items?
    list_items.any?
  end
end
```

## RSpec Test Structure

Generated RSpec tests include:

- **Setup and teardown blocks**
- **Action-specific scenarios** (index, show, new, create, edit, update, destroy)
- **Page Object Model integration**
- **Shared examples for common validations**
- **Screenshot capabilities for documentation**

Example:

```ruby
RSpec.describe "Users Index", type: :feature do
  let(:page_object) { UsersIndexPage.new }

  describe "visiting the users index page" do
    context "when there are users" do
      before { create_list(:user, 3) }

      it "displays the list of users" do
        page_object.visit_page
        
        expect(page_object).to be_loaded
        expect(page_object).to have_items
        expect(page_object.list_items.count).to eq(3)
      end
    end
  end
end
```

## Cucumber Test Structure

Generated Cucumber tests include:

- **Gherkin feature scenarios**
- **Background setup for common preconditions**
- **Step definitions with POM integration**
- **Data management steps**
- **Action-specific scenarios**

Example feature:

```gherkin
@users @index
Feature: Users Index
  As a user
  I want to view all users
  So that I can see all available users and navigate to specific ones

  Background:
    Given I am on the application
    And I am authenticated as a user

  Scenario: Viewing users list with items
    Given there are 3 users in the system
    When I visit the users index page
    Then I should see 3 users listed
    And each user should display its basic information
```

## Best Practices

### Page Object Models

1. **Keep POMs focused**: Each POM should represent a single page or view
2. **Use semantic element names**: Name elements based on their purpose, not implementation
3. **Include validations**: Add methods to verify page state and content
4. **Encapsulate actions**: Group related interactions into meaningful methods

### Test Organization

1. **Use descriptive test names**: Make test intentions clear
2. **Follow AAA pattern**: Arrange, Act, Assert
3. **Keep tests independent**: Each test should be able to run in isolation
4. **Use factories**: Leverage FactoryBot for test data creation

### Maintenance

1. **Regular cleanup**: Use cleanup tasks to remove unused files
2. **Validate POMs**: Run validation tasks to ensure POM integrity
3. **Monitor coverage**: Track test coverage and address gaps
4. **Update regularly**: Regenerate tests when routes change

## Dependencies

- **Rails**: >= 6.0
- **RSpec**: ~> 3.0 (for RSpec test generation)
- **Cucumber**: ~> 7.0 (for Cucumber test generation)
- **Capybara**: For page interaction in tests
- **Selenium WebDriver**: For screenshot capture (automatically included with Capybara)

## Development

After checking out the repo, run:

```bash
bundle install
```

To run the tests:

```bash
rspec
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

The gem is available as open source under the terms of the [MIT License](LICENSE).

## Support

For questions, issues, or contributions, please visit our [GitHub repository](https://github.com/rails-route-tester/rails-route-tester).

## Changelog

### Version 1.0.0

- Initial release
- Route analysis functionality
- Page Object Model generation
- RSpec feature test generation
- Cucumber feature test generation
- Comprehensive Rake task interface
- Test coverage analysis
- Cleanup and maintenance tools

