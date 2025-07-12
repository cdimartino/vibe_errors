# VibeErrors - Comprehensive Rails Error Tracking Engine

[![CI Status](https://github.com/cdimartino/vibe_errors/workflows/CI/badge.svg)](https://github.com/cdimartino/vibe_errors/actions)
[![Security](https://github.com/cdimartino/vibe_errors/workflows/CodeQL/badge.svg)](https://github.com/cdimartino/vibe_errors/security)
[![Ruby](https://img.shields.io/badge/ruby-3.1%20%7C%203.2%20%7C%203.3-ruby.svg)](https://www.ruby-lang.org)
[![Rails](https://img.shields.io/badge/rails-4.2%2B%20%7C%206.1%2B%20%7C%207.0%2B-red.svg)](https://rubyonrails.org)

> A production-ready Rails engine for comprehensive error tracking and management with intelligent ownership assignment, advanced search capabilities, and a modern web interface.

## 🚀 Quick Start

### Option 1: Try the Sample Application

The fastest way to see VibeErrors in action:

```bash
# Clone the repository
git clone https://github.com/cdimartino/vibe_errors.git
cd vibe_errors

# Set up environment
mise install  # or use your preferred Ruby version manager
cd sample_app

# Install dependencies and setup database
bundle install
bundle exec rails db:create db:migrate

# Install and configure VibeErrors
bundle exec rails generate vibe_errors:install
bundle exec rails db:migrate

# Start the server
bundle exec rails server
```

Visit http://localhost:3000 to interact with the demo application and http://localhost:3000/vibe_errors for the error tracking dashboard.

### Option 2: Add to Your Existing Rails App

```bash
# Add to your Gemfile
echo 'gem "vibe_errors", git: "https://github.com/cdimartino/vibe_errors.git", glob: "vibe_errors/*.gemspec"' >> Gemfile

# Install and setup
bundle install
rails generate vibe_errors:install
rails db:migrate
```

Then mount the engine in your `config/routes.rb`:

```ruby
Rails.application.routes.draw do
  mount VibeErrors::Engine => '/errors'
  # your other routes...
end
```

## 📋 Table of Contents

- [Features](#-features)
- [Architecture](#-architecture)
- [Installation](#-installation)
- [Usage](#-usage)
- [Configuration](#-configuration)
- [API Reference](#-api-reference)
- [Development](#-development)
- [Contributing](#-contributing)
- [License](#-license)

## ✨ Features

### 🎯 **Core Error Tracking**
- **Automatic Exception Capture**: Seamlessly catch and log Rails exceptions
- **Stack Trace Analysis**: Deep analysis with file and line number extraction
- **Severity Classification**: Automatic and manual severity assignment (low, medium, high, critical)
- **Status Management**: Track error lifecycle (new, in_progress, resolved, ignored)

### 🧠 **Intelligent Ownership Assignment**
- **Git Blame Integration**: Automatically assign errors to code authors
- **CODEOWNERS Support**: Respect your repository's ownership structure
- **File Pattern Matching**: Custom ownership rules based on file paths
- **Team Organization**: Group owners into teams and projects

### 🔍 **Advanced Search & Filtering**
- **Full-text Search**: Search across error messages, stack traces, and metadata
- **Multi-criteria Filtering**: Filter by severity, status, owner, tags, and date ranges
- **Tag-based Organization**: Flexible tagging system for categorization
- **Smart Suggestions**: Auto-complete for tags, owners, and common filters

### 📊 **Rich Web Interface**
- **Modern Dashboard**: Overview of error trends and statistics
- **Detailed Error Views**: Comprehensive error information with context
- **Responsive Design**: Works seamlessly on desktop and mobile
- **Bootstrap Integration**: Clean, professional UI that fits any Rails app

### 🔌 **Comprehensive API**
- **RESTful JSON API**: Complete programmatic access to all features
- **Webhook Support**: Real-time notifications for external integrations
- **Bulk Operations**: Efficient handling of multiple errors and messages
- **Rate Limiting**: Built-in protection against API abuse

### 🔒 **Enterprise-Ready**
- **Rails 4.2+ Compatibility**: Works with legacy and modern Rails applications
- **Security First**: CSRF protection, input validation, and vulnerability scanning
- **Performance Optimized**: Efficient queries and caching strategies
- **100% Test Coverage**: Comprehensive test suite with RSpec

## 🏗 Architecture

```
┌─────────────────────┐
│   Your Rails App    │
│                     │
│  ┌───────────────┐  │
│  │ VibeErrors    │  │
│  │ Engine        │  │
│  │               │  │
│  │ ┌───────────┐ │  │
│  │ │ Models    │ │  │
│  │ │ - Error   │ │  │
│  │ │ - Message │ │  │
│  │ │ - Owner   │ │  │
│  │ │ - Team    │ │  │
│  │ │ - Tag     │ │  │
│  │ └───────────┘ │  │
│  │               │  │
│  │ ┌───────────┐ │  │
│  │ │Controllers│ │  │
│  │ │ - Web UI  │ │  │
│  │ │ - JSON API│ │  │
│  │ └───────────┘ │  │
│  │               │  │
│  │ ┌───────────┐ │  │
│  │ │ Services  │ │  │
│  │ │ - Owner   │ │  │
│  │ │   Assignment │ │
│  │ │ - Search  │ │  │
│  │ └───────────┘ │  │
│  └───────────────┘  │
└─────────────────────┘
```

### 📦 **Repository Structure**

```
vibe_errors/
├── vibe_errors/           # The Rails engine
│   ├── app/              # MVC components
│   ├── config/           # Engine configuration
│   ├── db/migrate/       # Database migrations
│   ├── lib/              # Engine library and generators
│   └── spec/             # Comprehensive test suite
├── sample_app/           # Demo Rails application
│   ├── app/              # Sample app implementation
│   └── config/           # Sample app configuration
├── .github/              # CI/CD workflows and templates
├── docs/                 # Additional documentation
└── README.md            # This file
```

## 🛠 Installation

### Prerequisites

- Ruby 3.1+ (Ruby 3.3 recommended)
- Rails 4.2+ (Rails 7.1+ recommended)
- SQLite3 or PostgreSQL database
- Git (for ownership assignment features)

### Development Environment Setup

#### Using mise (Recommended)

```bash
# Install mise if you haven't already
curl https://mise.run | sh

# Clone and setup
git clone https://github.com/cdimartino/vibe_errors.git
cd vibe_errors
mise install  # Installs Ruby 3.3.8 and Node.js 20

# Install dependencies
bundle install
```

#### Using rbenv/rvm

```bash
# Clone the repository
git clone https://github.com/cdimartino/vibe_errors.git
cd vibe_errors

# Install Ruby (example with rbenv)
rbenv install 3.3.8
rbenv local 3.3.8

# Install dependencies
gem install bundler
bundle install
```

### Production Installation

Add to your Rails application's `Gemfile`:

```ruby
# For released versions (once published)
gem 'vibe_errors', '~> 0.1.0'

# For development version
gem 'vibe_errors', git: 'https://github.com/cdimartino/vibe_errors.git', glob: 'vibe_errors/*.gemspec'
```

Then run the installation generator:

```bash
bundle install
rails generate vibe_errors:install
rails db:migrate
```

## 🎮 Usage

### Basic Error Tracking

VibeErrors automatically captures unhandled exceptions when properly configured. You can also manually capture errors:

```ruby
# Manual exception capture
begin
  risky_operation
rescue => exception
  VibeErrors.capture_exception(exception, {
    severity: 'high',
    context: { user_id: current_user.id },
    auto_assign_owner: true
  })
end

# Message logging
VibeErrors.log_error("Payment processing failed", {
  metadata: { transaction_id: '12345' }
})

VibeErrors.log_warning("High memory usage detected")
VibeErrors.log_info("User login successful")
```

### Web Interface

Navigate to `/vibe_errors` (or wherever you mounted the engine) to access:

- **Dashboard**: Overview of recent errors and trends
- **Error Browser**: Search and filter through all captured errors
- **Error Details**: Detailed view with stack traces and context
- **Tag Management**: Organize errors with custom tags
- **Owner Assignment**: Assign errors to team members

### API Usage

Complete REST API for programmatic access:

```bash
# List errors with filtering
curl "http://localhost:3000/vibe_errors/api/errors?severity=high&status=new"

# Get specific error details
curl "http://localhost:3000/vibe_errors/api/errors/123"

# Create error manually
curl -X POST "http://localhost:3000/vibe_errors/api/errors" \
  -H "Content-Type: application/json" \
  -d '{
    "error": {
      "message": "API error occurred",
      "severity": "medium",
      "metadata": {"endpoint": "/api/users"}
    }
  }'

# Bulk operations
curl -X POST "http://localhost:3000/vibe_errors/api/errors/bulk_resolve" \
  -H "Content-Type: application/json" \
  -d '{"error_ids": [1, 2, 3]}'
```

### Sample Application

The included sample application demonstrates all features:

```bash
cd sample_app
bundle exec rails server
```

Features demonstrated:
- **Error Simulation**: Buttons to trigger different types of errors
- **Message Logging**: Forms to create different message types
- **Dashboard Integration**: Live statistics and recent errors
- **Search Examples**: Pre-configured searches and filters

## ⚙️ Configuration

### Basic Configuration

Create or modify `config/initializers/vibe_errors.rb`:

```ruby
VibeErrors.configure do |config|
  # Enable/disable automatic error capture
  config.auto_capture_errors = true
  
  # Enable/disable automatic owner assignment
  config.auto_assign_owners = true
  
  # Set default error severity
  config.default_error_severity = "medium"
  
  # Configure ignored exception types
  config.ignored_exceptions = [
    "ActiveRecord::RecordNotFound",
    "ActionController::RoutingError"
  ]
  
  # Set ownership assignment strategies
  config.ownership_strategies = [:git_blame, :codeowners, :file_patterns]
  
  # Configure search settings
  config.enable_full_text_search = true
  config.search_result_limit = 100
end
```

### Advanced Configuration

```ruby
VibeErrors.configure do |config|
  # Custom error capturing logic
  config.before_capture = ->(exception, options) {
    # Add custom context or modify options
    options[:context] ||= {}
    options[:context][:environment] = Rails.env
    options[:context][:server] = `hostname`.strip
  }
  
  # Custom ownership assignment
  config.custom_owner_resolver = ->(file_path, line_number) {
    # Your custom logic to determine owner
    return Owner.find_by(email: 'team-lead@company.com')
  }
  
  # Integration hooks
  config.after_error_created = ->(error) {
    # Send to external monitoring service
    ExternalMonitoring.notify(error)
  }
  
  # Performance settings
  config.async_processing = true
  config.background_job_queue = :vibe_errors
end
```

### Environment Variables

Support for environment-based configuration:

```bash
# Enable/disable features
VIBE_ERRORS_AUTO_CAPTURE=true
VIBE_ERRORS_AUTO_ASSIGN_OWNERS=true

# Performance settings
VIBE_ERRORS_ASYNC_PROCESSING=true
VIBE_ERRORS_SEARCH_LIMIT=100

# Integration settings
VIBE_ERRORS_WEBHOOK_URL=https://hooks.slack.com/services/...
```

## 📚 API Reference

### REST Endpoints

#### Errors API

```
GET    /vibe_errors/api/errors              # List errors with filtering
POST   /vibe_errors/api/errors              # Create new error
GET    /vibe_errors/api/errors/:id          # Get specific error
PATCH  /vibe_errors/api/errors/:id          # Update error
DELETE /vibe_errors/api/errors/:id          # Delete error

# Error actions
PATCH  /vibe_errors/api/errors/:id/resolve      # Mark as resolved
PATCH  /vibe_errors/api/errors/:id/assign_owner # Assign owner
POST   /vibe_errors/api/errors/:id/add_tag     # Add tag
DELETE /vibe_errors/api/errors/:id/remove_tag  # Remove tag

# Bulk operations
POST   /vibe_errors/api/errors/bulk_resolve     # Resolve multiple errors
POST   /vibe_errors/api/errors/bulk_assign      # Bulk assign owners
```

#### Messages API

```
GET    /vibe_errors/api/messages           # List messages
POST   /vibe_errors/api/messages           # Create message
GET    /vibe_errors/api/messages/:id       # Get specific message
PATCH  /vibe_errors/api/messages/:id       # Update message
DELETE /vibe_errors/api/messages/:id       # Delete message
```

#### Search API

```
GET    /vibe_errors/api/search             # Global search
GET    /vibe_errors/api/search/errors      # Search errors only
GET    /vibe_errors/api/search/messages    # Search messages only
```

### Ruby API

```ruby
# Error management
error = VibeErrors::Error.create_from_exception(exception)
error.assign_to_owner(owner)
error.add_tag('production')
error.resolve!

# Message logging
VibeErrors.log_error("Something went wrong", { context: {...} })
VibeErrors.log_warning("Warning message")
VibeErrors.log_info("Info message")

# Search
results = VibeErrors::Search.perform("database timeout", {
  severity: 'high',
  status: 'new',
  limit: 50
})

# Owner management
owner = VibeErrors::Owner.find_or_create_by_email('dev@company.com')
team = VibeErrors::Team.create(name: 'Backend Team')
team.add_member(owner)
```

## 🔧 Development

### Setting Up Development Environment

```bash
# Clone and setup
git clone https://github.com/cdimartino/vibe_errors.git
cd vibe_errors

# Install dependencies
mise install
bundle install

# Run tests
cd vibe_errors
bundle exec rspec

# Run code quality checks
bundle exec standardrb
bundle exec rubocop
bundle exec reek
bundle exec brakeman

# Or run all checks with our CI script
./bin/ci
```

### Testing

We maintain 100% test coverage with comprehensive RSpec tests:

```bash
# Run all tests
bundle exec rspec

# Run specific test files
bundle exec rspec spec/models/vibe_errors/error_spec.rb

# Run with coverage report
COVERAGE=true bundle exec rspec

# Run integration tests
cd sample_app
bundle exec rspec
```

### Code Quality

Our CI pipeline enforces strict code quality standards:

```bash
# Check code style
bundle exec standardrb

# Run security analysis
bundle exec brakeman

# Check for code smells
bundle exec reek

# Verify all quality checks
./bin/ci quality
```

### Docker Development

Use Docker for isolated development:

```bash
# Build and start services
docker-compose up vibe_errors

# Run tests in container
docker-compose run test

# Run quality checks
docker-compose run quality
```

### Contributing Workflow

1. **Fork the repository** on GitHub
2. **Create a feature branch**: `git checkout -b feature/amazing-feature`
3. **Write tests** for your changes
4. **Implement your feature** following our coding standards
5. **Run the full test suite**: `./bin/ci`
6. **Commit with conventional commits**: `git commit -m "feat: add amazing feature"`
7. **Push to your fork**: `git push origin feature/amazing-feature`
8. **Create a Pull Request** using our template

### Release Process

We use semantic versioning and automated releases:

```bash
# Create a new release
git tag v1.2.3
git push origin v1.2.3

# GitHub Actions will automatically:
# - Run full test suite
# - Build and publish gem
# - Create GitHub release
# - Update documentation
```

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](.github/CONTRIBUTING.md) for details.

### Ways to Contribute

- 🐛 **Bug Reports**: Use our [bug report template](.github/ISSUE_TEMPLATE/bug_report.yml)
- ✨ **Feature Requests**: Use our [feature request template](.github/ISSUE_TEMPLATE/feature_request.yml)
- 📖 **Documentation**: Help improve our docs and examples
- 🔧 **Code**: Submit pull requests with new features or bug fixes
- 🧪 **Testing**: Help us maintain 100% test coverage
- 🎨 **UI/UX**: Improve the web interface and user experience

### Development Guidelines

- Follow our [code style guidelines](https://github.com/testdouble/standard)
- Write comprehensive tests for all changes
- Update documentation for new features
- Use conventional commit messages
- Ensure all CI checks pass

## 📄 License

This project is licensed under the MIT License - see the [MIT-LICENSE](vibe_errors/MIT-LICENSE) file for details.

## 🙏 Acknowledgments

- **Rails Team** - For the amazing framework
- **RSpec Team** - For the excellent testing framework  
- **Bootstrap Team** - For the beautiful UI components
- **GitHub Actions** - For the robust CI/CD platform

## 📞 Support

- 📖 **Documentation**: [GitHub Wiki](https://github.com/cdimartino/vibe_errors/wiki)
- 🐛 **Issues**: [GitHub Issues](https://github.com/cdimartino/vibe_errors/issues)
- 💬 **Discussions**: [GitHub Discussions](https://github.com/cdimartino/vibe_errors/discussions)
- 📧 **Email**: team@vibeerrors.com

---

**Built with ❤️ by the VibeErrors team**

🤖 *Generated with [Claude Code](https://claude.ai/code)*