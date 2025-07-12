# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Rails engine called "VibeErrors" designed for comprehensive error tracking and management in Rails applications. The engine provides APIs for creating errors and messages, web interfaces for viewing and searching errors, and comprehensive error management features including tagging, severity levels, ownership assignment, and more.

## Project Status

Currently, this repository contains only the project specification (`Prompt for rails app.md`). The Rails engine has not been created yet and needs to be implemented according to the detailed requirements in the specification.

## Key Requirements from Specification

- Mise for ruby, js, and other core tool integration
- **Target Compatibility**: Rails 4.2+ compatibility required
- **Ruby Version**: Ruby 3.4 with latest stable Rails version
- **Testing**: RSpec with 100% unit test coverage + integration tests
- **Code Quality Tools**: 
  - standardrb for code formatting
  - rubocop for code style enforcement  
  - reek for code smell detection
  - brakeman for security analysis
- **Package Management**: Use mise for Ruby version management and bundler for gem installation
- **CI/CD**: GitHub Actions pipeline with deployment to Hanami test environment

## Development Setup Commands

Since the Rails engine hasn't been created yet, the first step is to generate the engine structure:

```bash
# Install gems using bundler (after creating Gemfile)
bundle install

# Generate the Rails engine
rails plugin new vibe_errors --mountable

# Run tests (once implemented)
bundle exec rspec

# Code quality checks
bundle exec standardrb
bundle exec rubocop
bundle exec reek
bundle exec brakeman
```

## Architecture Overview

The engine will implement:

1. **Error Management System**: APIs for creating, tagging, and managing errors and messages
2. **Web Interface**: Views for browsing, searching, and managing errors
3. **Ownership System**: Automatic assignment of error ownership based on stack trace analysis
4. **Search & Filter System**: Multi-criteria search by tags, severity, location, message, stack trace
5. **Project Management Features**: Status tracking, priority assignment, due dates, resolutions

## Core Components (To Be Implemented)

- **Models**: Error, Message, Tag, Owner, Team, Project models with associations
- **Controllers**: API endpoints and web interface controllers
- **Views**: Error browsing, search, and management interfaces
- **Services**: Error capture, ownership assignment, and search logic
- **Generators**: Installation generator for host Rails applications
- **Routes**: Mountable engine routes for API and web interface

## Installation in Host Rails App

The engine should provide:
- Generator for easy installation: `rails generate vibe_errors:install`
- Rake task for setup: `rake vibe_errors:setup`
- Automatic route mounting in host application
