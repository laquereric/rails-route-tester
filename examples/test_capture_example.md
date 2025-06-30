# Test Capture Example

This example demonstrates how the Rails Route Tester gem captures HTML and PNG files during test execution.

## Generated Test Structure

When you generate tests using the gem, they automatically include test capture functionality:

### RSpec Example

```ruby
RSpec.describe "Users Index", type: :feature do
  let(:page_object) { UsersIndexPage.new }

  describe "visiting the users index page" do
    context "when there are users" do
      before { create_list(:user, 3) }

      it "displays the list of users" do
        page_object.visit_page
        capture_test_step("after_visit_page")  # ← Captures HTML and PNG
        
        expect(page_object).to be_loaded
        capture_test_step("after_loaded_check")  # ← Captures HTML and PNG
        
        expect(page_object).to have_items
        capture_test_step("after_items_check")  # ← Captures HTML and PNG
        
        expect(page_object.list_items.count).to eq(3)
        capture_test_step("after_count_check")  # ← Captures HTML and PNG
      end
    end
  end
end
```

### Cucumber Example

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
    When I visit the users index page  # ← Automatically captures
    Then I should see 3 users listed   # ← Automatically captures
    And each user should display its basic information  # ← Automatically captures
```

## Generated Results

After running the tests, you'll find results in the `route_tests_results` directory:

```
route_tests_results/
├── displays_the_list_of_users_20250101_143022_456/
│   ├── displays_the_list_of_users_20250101_143022_456_after_visit_page.html
│   ├── displays_the_list_of_users_20250101_143022_456_after_visit_page.png
│   ├── displays_the_list_of_users_20250101_143022_456_after_loaded_check.html
│   ├── displays_the_list_of_users_20250101_143022_456_after_loaded_check.png
│   ├── displays_the_list_of_users_20250101_143022_456_after_items_check.html
│   ├── displays_the_list_of_users_20250101_143022_456_after_items_check.png
│   ├── displays_the_list_of_users_20250101_143022_456_after_count_check.html
│   ├── displays_the_list_of_users_20250101_143022_456_after_count_check.png
│   └── displays_the_list_of_users_20250101_143022_456_metadata.json
└── viewing_users_list_with_items_20250101_143025_789/
    ├── viewing_users_list_with_items_20250101_143025_789_visit_users_index_page.html
    ├── viewing_users_list_with_items_20250101_143025_789_visit_users_index_page.png
    ├── viewing_users_list_with_items_20250101_143025_789_verify_users_index_page_loaded.html
    ├── viewing_users_list_with_items_20250101_143025_789_verify_users_index_page_loaded.png
    └── viewing_users_list_with_items_20250101_143025_789_metadata.json
```

## HTML File with Metadata Overlay

The captured HTML files include a visible metadata overlay:

```html
<!DOCTYPE html>
<html>
<head>
  <title>Users - My Application</title>
</head>
<body>
  <!-- Test Capture Metadata: test_id=displays_the_list_of_users_20250101_143022_456, step_name=after_visit_page, timestamp=2025-01-01T14:30:22.456Z -->
  
  <div style="position: fixed; top: 0; left: 0; background: rgba(0,0,0,0.8); color: white; padding: 10px; font-family: monospace; font-size: 12px; z-index: 9999; max-width: 100%; word-wrap: break-word;">
    <strong>Test Capture:</strong> displays_the_list_of_users_20250101_143022_456<br>
    <strong>Step:</strong> after_visit_page<br>
    <strong>Time:</strong> 2025-01-01 14:30:22<br>
    <strong>URL:</strong> http://localhost:3000/users
  </div>
  
  <!-- Original page content -->
  <h1>Users</h1>
  <div class="users-list">
    <!-- ... rest of the page content ... -->
  </div>
</body>
</html>
```

## Metadata JSON File

Each test directory includes a metadata file with detailed information:

```json
{
  "test_id": "displays_the_list_of_users_20250101_143022_456",
  "example_name": "displays the list of users",
  "step_name": "after_visit_page",
  "timestamp": "2025-01-01T14:30:22.456Z",
  "current_url": "http://localhost:3000/users",
  "page_title": "Users - My Application",
  "files": {
    "html": "displays_the_list_of_users_20250101_143022_456_after_visit_page.html",
    "png": "displays_the_list_of_users_20250101_143022_456_after_visit_page.png"
  },
  "browser_info": {
    "user_agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36...",
    "window_size": {
      "width": 1920,
      "height": 1080
    }
  }
}
```

## Managing Test Results

Use the provided rake tasks to manage your test results:

```bash
# List all test results
rake results:list

# Show details for a specific test
rake results:show[displays_the_list_of_users_20250101_143022_456]

# Generate a summary report
rake results:report

# Open the results directory
rake results:open

# Clean up old results (older than 7 days)
rake results:cleanup

# Clean up old results (older than 30 days)
rake results:cleanup[30]
```

## Benefits

1. **Debugging**: Easily see what the page looked like at each step
2. **Documentation**: Create visual documentation of your application
3. **Regression Testing**: Compare screenshots across test runs
4. **Bug Reports**: Include HTML and screenshots in bug reports
5. **CI/CD Integration**: Archive test results for later analysis
6. **Automated Cleanup**: Old results are automatically cleaned up

## Configuration Options

The test capture is automatically enabled, but you can customize it:

```ruby
# Enable step-by-step capture for debugging
RSpec.configure do |config|
  config.before(:each, type: :feature, capture_steps: true) do |example|
    capture_test_step("before_step")
  end
end

# Disable capture for specific scenarios (Cucumber)
@no_capture
Scenario: This won't capture results
  Given I visit the users page
  Then I should see the users list
``` 