require_relative "lib/vibe_errors/version"

Gem::Specification.new do |spec|
  spec.name = "vibe_errors"
  spec.version = VibeErrors::VERSION
  spec.authors = ["VibeErrors Team"]
  spec.email = ["team@vibeerrors.com"]
  spec.homepage = "https://github.com/vibeerrors/vibe_errors"
  spec.summary = "Comprehensive error tracking and management for Rails applications"
  spec.description = "VibeErrors is a Rails engine that provides comprehensive error tracking and management capabilities, including error capture, tagging, ownership assignment, and web interface for browsing and managing errors."
  spec.license = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/vibeerrors/vibe_errors"
  spec.metadata["changelog_uri"] = "https://github.com/vibeerrors/vibe_errors/blob/main/CHANGELOG.md"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.required_ruby_version = ">= 2.7.0"

  # Support Rails 4.2+ as specified in requirements
  spec.add_dependency "rails", ">= 4.2.0"
  spec.add_dependency "sqlite3", "~> 1.4"

  spec.add_development_dependency "rspec-rails", "~> 6.0"
  spec.add_development_dependency "factory_bot_rails", "~> 6.4"
  spec.add_development_dependency "faker", "~> 3.2"
  spec.add_development_dependency "standard", ">= 1.35.1"
  spec.add_development_dependency "rubocop", "~> 1.57"
  spec.add_development_dependency "reek", "~> 6.1"
  spec.add_development_dependency "brakeman", "~> 7.0"
  spec.add_development_dependency "simplecov", "~> 0.22"
  spec.add_development_dependency "shoulda-matchers", "~> 6.0"
  spec.add_development_dependency "database_cleaner-active_record", "~> 2.1"
  spec.add_development_dependency "rspec_junit_formatter", "~> 0.6"
end
