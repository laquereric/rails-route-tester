# Testing Guide - Rails Route Tester Example App

This guide will walk you through testing the example application and seeing the test capture functionality in action.

## 🚀 Quick Start

1. **Setup the application**:
   ```bash
   cd examples/example_app
   chmod +x setup.sh
   ./setup.sh
   ```

2. **Start the server**:
   ```bash
   rails server
   ```

3. **Visit the application**: http://localhost:3000

## 🧪 Running Tests

### RSpec Tests

Run all RSpec feature tests:
```bash
rspec spec/features/
```

Run a specific test file:
```bash
rspec spec/features/users_index_spec.rb
```

Run tests with detailed output:
```bash
rspec spec/features/ --format documentation
```

### Cucumber Tests

Run all Cucumber tests:
```bash
cucumber
```

Run a specific feature:
```bash
cucumber features/users_index.feature
```

Run tests with tags:
```bash
cucumber --tags @users
```

## 📸 Test Capture Results

After running tests, you'll find captured results in the `route_tests_results/` directory.

### Viewing Results

List all test results:
```bash
rake results:list
```

Show details for a specific test:
```bash
rake results:show[test_name_timestamp]
```

Generate a summary report:
```bash
rake results:report
```

Open the results directory:
```bash
rake results:open
```

### Results Structure

Each test execution creates a directory with:
- **HTML files**: Page HTML with metadata overlay
- **PNG files**: Screenshots at each step
- **JSON metadata**: Test information and browser details

Example structure:
```
route_tests_results/
├── displays_the_list_of_users_20250101_143022_456/
│   ├── displays_the_list_of_users_20250101_143022_456_after_visit_page.html
│   ├── displays_the_list_of_users_20250101_143022_456_after_visit_page.png
│   ├── displays_the_list_of_users_20250101_143022_456_after_loaded_check.html
│   ├── displays_the_list_of_users_20250101_143022_456_after_loaded_check.png
│   └── displays_the_list_of_users_20250101_143022_456_metadata.json
```

## 🎯 Test Scenarios

### Navigation Flow

1. **Home Page** (`/`)
   - View welcome message and stats
   - Click "View All Users" link
   - Click "About Us" link

2. **Users Index** (`/users`)
   - View list of users
   - Search for users
   - Click on individual user links
   - Click "Add New User" button

3. **User Show** (`/users/:id`)
   - View user details
   - Click "Edit User" link
   - Click "Delete User" link

4. **User Edit** (`/users/:id/edit`)
   - Edit user information
   - Submit form with valid data
   - Submit form with invalid data
   - Cancel editing

5. **User New** (`/users/new`)
   - Create new user
   - Fill form with valid data
   - Fill form with invalid data
   - Cancel creation

### Test Coverage

The generated tests cover:

- **Page Loading**: Verify pages load correctly
- **Navigation**: Test links between pages
- **Forms**: Test form submission and validation
- **Search**: Test search functionality
- **CRUD Operations**: Create, read, update, delete users
- **Responsive Design**: Test on different screen sizes
- **Error Handling**: Test error states and messages

## 🔧 Customization

### Adding New Routes

1. Add routes to `config/routes.rb`
2. Create controllers and views
3. Regenerate tests:
   ```bash
   rake tests:generate:all
   ```

### Modifying Test Capture

Edit `spec/support/feature_helper.rb` to customize capture behavior:

```ruby
# Enable step-by-step capture for debugging
RSpec.configure do |config|
  config.before(:each, type: :feature, capture_steps: true) do |example|
    capture_test_step("before_step")
  end
end
```

### Custom Page Object Models

Generated POMs are in `spec/support/page_objects/`. You can customize them:

```ruby
class UsersIndexPage < BasePage
  # Add custom elements
  element :custom_button, '.custom-button'
  
  # Add custom methods
  def click_custom_button
    custom_button.click
    capture_test_step("after_custom_button_click")
  end
end
```

## 📊 Results Analysis

### HTML Files

Each HTML file includes:
- Original page content
- Metadata overlay with test information
- Timestamp and URL information

### PNG Screenshots

Screenshots capture:
- Full page view
- Current state at each test step
- Visual verification of UI elements

### Metadata Files

JSON files contain:
- Test name and step information
- Browser details (user agent, window size)
- File paths and timestamps
- Current URL and page title

## 🧹 Maintenance

### Cleanup Old Results

Clean up results older than 7 days:
```bash
rake results:cleanup
```

Clean up results older than 30 days:
```bash
rake results:cleanup[30]
```

### Regenerate Tests

If you modify the application, regenerate tests:
```bash
rake tests:generate:all
```

## 🐛 Troubleshooting

### Common Issues

1. **Tests fail to capture screenshots**:
   - Ensure Selenium WebDriver is installed
   - Check that Chrome/Chromium is available
   - Verify Capybara configuration

2. **Results directory not created**:
   - Check file permissions
   - Ensure the application can write to the current directory

3. **HTML files are empty**:
   - Verify the application is running
   - Check that pages are accessible
   - Review test setup and configuration

### Debug Mode

Enable detailed logging:
```bash
RSPEC_LOG_LEVEL=debug rspec spec/features/
```

### Manual Testing

Test the capture functionality manually:
```ruby
# In Rails console
require 'rails_route_tester/test_capture_helper'
RailsRouteTester::TestCaptureHelper.capture_test_results("manual_test", "manual_step")
```

## 📚 Additional Resources

- [Rails Route Tester Documentation](../README.md)
- [Test Capture Example](../test_capture_example.md)
- [RSpec Documentation](https://rspec.info/)
- [Cucumber Documentation](https://cucumber.io/docs)

## 🎉 Next Steps

1. **Explore the application**: Navigate through all pages
2. **Run tests**: Execute RSpec and Cucumber tests
3. **View results**: Examine captured HTML and PNG files
4. **Customize**: Modify tests and capture behavior
5. **Integrate**: Use these patterns in your own applications

Happy testing! 🚀 