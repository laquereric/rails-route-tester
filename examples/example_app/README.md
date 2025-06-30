# Example Rails Application

This is a simple Rails application that demonstrates the Rails Route Tester gem's test capture functionality. It includes multiple pages with navigation between them to show how HTML and PNG files are captured at every test step.

## Application Structure

The example app includes:

1. **Home Page** (`/`) - Landing page with navigation links
2. **Users Index Page** (`/users`) - List of users with links to individual users
3. **User Show Page** (`/users/:id`) - Individual user details with edit/delete options
4. **User Edit Page** (`/users/:id/edit`) - Form to edit user information

## Features

- **Navigation**: Links between all pages
- **CRUD Operations**: Create, read, update, delete users
- **Search Functionality**: Search through users
- **Responsive Design**: Works on different screen sizes
- **Flash Messages**: Success and error notifications

## Setup Instructions

1. **Install Dependencies**:
   ```bash
   cd examples/example_app
   bundle install
   ```

2. **Setup Database**:
   ```bash
   rails db:create
   rails db:migrate
   rails db:seed
   ```

3. **Start the Server**:
   ```bash
   rails server
   ```

4. **Visit the Application**:
   Open http://localhost:3000 in your browser

## Test Capture Demonstration

This app is designed to demonstrate the test capture functionality:

1. **Generate Tests**: Use the Rails Route Tester gem to generate tests
2. **Run Tests**: Execute the tests to see capture in action
3. **View Results**: Check the `route_tests_results` directory for captured files

## Generated Test Files

When you run the test generation, you'll get:

- **Page Object Models**: `spec/support/page_objects/`
- **RSpec Tests**: `spec/features/`
- **Cucumber Tests**: `features/`

## Test Results

After running tests, check the `route_tests_results` directory for:

- HTML files with metadata overlays
- PNG screenshots at each step
- JSON metadata files with test information

## Navigation Flow

```
Home Page (/)
    ↓
Users Index (/users)
    ↓
User Show (/users/1)
    ↓
User Edit (/users/1/edit)
```

Each page includes:
- Navigation links
- Content specific to the page
- Interactive elements
- Responsive design elements 