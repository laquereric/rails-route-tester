#!/bin/bash

echo "🚀 Setting up Rails Route Tester Example Application"
echo "=================================================="

# Check if we're in the right directory
if [ ! -f "Gemfile" ]; then
    echo "❌ Error: Please run this script from the example_app directory"
    exit 1
fi

echo "📦 Installing dependencies..."
bundle install

echo "🗄️  Setting up database..."
rails db:create
rails db:migrate
rails db:seed

echo "🎯 Generating test files with Rails Route Tester..."
echo "This will create Page Object Models, RSpec tests, and Cucumber tests"

# Generate POMs for all routes
echo "📝 Generating Page Object Models..."
rake pom:generate:all

# Generate RSpec tests
echo "🧪 Generating RSpec tests..."
rake tests:generate:rspec_all

# Generate Cucumber tests
echo "🥒 Generating Cucumber tests..."
rake tests:generate:cucumber_all

echo ""
echo "✅ Setup complete!"
echo ""
echo "🎮 Next steps:"
echo "1. Start the server: rails server"
echo "2. Visit: http://localhost:3000"
echo "3. Explore the application and test the navigation"
echo ""
echo "🧪 To run tests and see capture in action:"
echo "1. Run RSpec tests: rspec spec/features/"
echo "2. Run Cucumber tests: cucumber"
echo "3. View captured results: rake results:list"
echo ""
echo "📁 Test results will be stored in: route_tests_results/"
echo "📊 View results summary: rake results:report"
echo "🔍 Open results directory: rake results:open"
echo ""
echo "Happy testing! 🎉" 