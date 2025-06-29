# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-01-01

### Added

#### Core Functionality
- Route analysis and listing capabilities
- Page Object Model (POM) generation for all Rails routes
- RSpec feature test generation with POM integration
- Cucumber feature test generation with step definitions
- Comprehensive Rake task interface

#### Route Analysis Features
- `routes:list` - List all routes in tabular format
- `routes:with_tests` - Show routes with associated test files
- `routes:without_tests` - Identify untested routes
- `routes:without_poms` - Find routes missing Page Object Models
- `routes:coverage` - Display test coverage statistics

#### Page Object Model Features
- `pom:generate[controller,action]` - Generate POM for specific route
- `pom:generate:all` - Generate POMs for all routes
- `pom:generate:missing` - Generate POMs only for routes that need them
- `pom:list` - List all existing POMs
- `pom:validate` - Validate POM structure and syntax
- `pom:cleanup` - Remove unused POM files
- Base POM class with common functionality
- Action-specific element and method generation
- Capybara integration for page interactions

#### RSpec Integration
- `tests:generate:rspec[controller,action]` - Generate RSpec test for specific route
- `tests:generate:rspec_all` - Generate RSpec tests for all routes
- Action-specific test scenarios (index, show, new, create, edit, update, destroy)
- Shared examples for common validations
- Screenshot capabilities for documentation
- Support file generation (spec_helper.rb, rails_helper.rb, feature_helper.rb)
- FactoryBot integration

#### Cucumber Integration
- `tests:generate:cucumber[controller,action]` - Generate Cucumber test for specific route
- `tests:generate:cucumber_all` - Generate Cucumber tests for all routes
- Gherkin feature file generation with realistic scenarios
- Step definition files with POM integration
- Background setup for common preconditions
- Data management steps for test setup
- Support file generation (env.rb, world_extensions.rb, common_steps.rb)
- Cucumber configuration (cucumber.yml)

#### Test Management
- `tests:generate:both[controller,action]` - Generate both RSpec and Cucumber tests
- `tests:generate:all` - Generate complete test suite (POMs + RSpec + Cucumber)
- `tests:list` - List all existing test files
- `tests:run_rspec` - Run all RSpec feature tests
- `tests:run_cucumber` - Run all Cucumber feature tests
- `tests:run_all` - Run complete test suite
- `tests:cleanup` - Remove unused test files

#### Configuration System
- Configurable base paths for POMs, RSpec tests, and Cucumber features
- Test framework preference setting
- Rails integration via Railtie
- Environment-specific configuration support

#### Developer Experience
- Comprehensive documentation and README
- Usage examples for common scenarios
- Error handling and user-friendly messages
- Progress indicators for bulk operations
- Validation and cleanup tools
- CI/CD integration examples

### Technical Implementation

#### Architecture
- Modular design with separate generators for POMs, RSpec, and Cucumber
- Route analyzer for Rails route introspection
- Test finder for existing test file detection
- Configuration system for customization

#### Dependencies
- Rails >= 6.0 compatibility
- RSpec ~> 3.0 integration
- Cucumber ~> 7.0 integration
- Capybara for page interactions
- Ruby >= 2.7.0 support

#### File Structure
- Organized gem structure following Ruby conventions
- Separate rake task files for different functionality areas
- Generator classes for each test type
- Support files for test framework integration

### Documentation
- Comprehensive README with installation and usage instructions
- Detailed usage examples for real-world scenarios
- API documentation for all public methods
- Configuration guide for different project structures
- Best practices for test maintenance
- Changelog for version tracking

### Quality Assurance
- Input validation for all rake tasks
- Error handling with helpful messages
- File existence checks before operations
- Syntax validation for generated files
- Cleanup tools for maintenance

This initial release provides a complete solution for Rails route testing with Page Object Models, supporting both RSpec and Cucumber testing frameworks with comprehensive automation and maintenance tools.

