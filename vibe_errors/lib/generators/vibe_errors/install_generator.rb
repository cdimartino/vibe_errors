require "rails/generators"

module VibeErrors
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      desc "Install VibeErrors in your Rails application"

      def create_initializer
        template "initializer.rb", "config/initializers/vibe_errors.rb"
      end

      def create_migration
        rails_command "vibe_errors:install:migrations"
      end

      def mount_engine
        inject_into_file "config/routes.rb", after: "Rails.application.routes.draw do\n" do
          "  mount VibeErrors::Engine => '/vibe_errors'\n"
        end
      end

      def create_application_controller_integration
        template "application_controller_integration.rb", "app/controllers/concerns/vibe_errors_integration.rb"
      end

      def add_exception_handling
        inject_into_file "app/controllers/application_controller.rb", after: "class ApplicationController < ActionController::Base\n" do
          "  include VibeErrorsIntegration\n"
        end
      end

      def create_sample_owners
        template "sample_owners.rb", "db/seeds/vibe_errors_owners.rb"
      end

      def show_readme
        say "\n"
        say "🎉 VibeErrors has been successfully installed!"
        say "\n"
        say "Next steps:"
        say "1. Run migrations: rails db:migrate"
        say "2. (Optional) Create sample data: rails db:seed"
        say "3. Start your Rails server and visit /vibe_errors"
        say "\n"
        say "Configuration:"
        say "- Edit config/initializers/vibe_errors.rb to customize settings"
        say "- The engine is mounted at /vibe_errors (change in config/routes.rb)"
        say "\n"
        say "Documentation: https://github.com/vibeerrors/vibe_errors"
        say "\n"
      end
    end
  end
end
