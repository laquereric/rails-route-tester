Gem::Specification.new do |spec|
  spec.name          = "rails_route_tester"
  spec.version       = "1.0.0"
  spec.authors       = ["Rails Route Tester Contributors"]
  spec.email         = ["contributors@rails-route-tester.com"]

  spec.summary       = "Rails gem for route testing and Page Object Model generation"
  spec.description   = "Provides Rake tasks to list routes, generate Page Object Models, and create RSpec/Cucumber tests for Rails applications"
  spec.homepage      = "https://github.com/rails-route-tester/rails-route-tester"
  spec.license       = "MIT"

  spec.required_ruby_version = ">= 2.7.0"

  spec.files         = Dir["lib/**/*", "README.md", "LICENSE", "Rakefile"]
  spec.require_paths = ["lib"]

  # Runtime dependencies
  spec.add_dependency "rails", ">= 6.0"
  spec.add_dependency "rake", ">= 12.0"

  # Development dependencies
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "cucumber", "~> 7.0"
  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "pry", "~> 0.14"

  # Metadata
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/rails-route-tester/rails-route-tester"
  spec.metadata["changelog_uri"] = "https://github.com/rails-route-tester/rails-route-tester/blob/main/CHANGELOG.md"
end

