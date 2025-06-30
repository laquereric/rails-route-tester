require "rails"

module RailsRouteTester
  class Railtie < Rails::Railtie
    railtie_name :rails_route_tester

    rake_tasks do
      load "rails_route_tester/rake_tasks/routes.rake"
      load "rails_route_tester/rake_tasks/pom.rake"
      load "rails_route_tester/rake_tasks/tests.rake"
      load "rails_route_tester/rake_tasks/results.rake"
    end
  end
end

