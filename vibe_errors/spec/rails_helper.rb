require "spec_helper"

ENV["RAILS_ENV"] ||= "test"
require_relative "../test/dummy/config/environment"

abort("The Rails environment is running in production mode!") if Rails.env.production?

require "rspec/rails"
require "factory_bot_rails"
require "shoulda/matchers"
require "database_cleaner/active_record"
require "simplecov"

# Start SimpleCov
SimpleCov.start "rails" do
  add_filter "/spec/"
  add_filter "/test/"
  add_filter "/config/"
  add_filter "/vendor/"
  add_filter "/db/"

  add_group "Models", "app/models"
  add_group "Controllers", "app/controllers"
  add_group "Services", "app/services"
  add_group "Helpers", "app/helpers"
  add_group "Libraries", "lib"

  minimum_coverage 95
  minimum_coverage_by_file 80
end

Dir[VibeErrors::Engine.root.join("spec", "support", "**", "*.rb")].sort.each { |f| require f }

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  # FactoryBot configuration
  config.include FactoryBot::Syntax::Methods

  # Database Cleaner configuration
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  # Shoulda Matchers configuration
  config.include(Shoulda::Matchers::ActiveModel, type: :model)
  config.include(Shoulda::Matchers::ActiveRecord, type: :model)

  # Controller test helpers
  config.include VibeErrors::Engine.routes.url_helpers, type: :controller
  config.include VibeErrors::Engine.routes.url_helpers, type: :request

  # Reset VibeErrors configuration before each test
  config.before(:each) do
    VibeErrors.reset_configuration!
  end
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
