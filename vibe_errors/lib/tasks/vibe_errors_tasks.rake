namespace :vibe_errors do
  desc "Setup VibeErrors in the host application"
  task setup: :environment do
    puts "Setting up VibeErrors..."

    # Run migrations
    puts "Running migrations..."
    Rake::Task["vibe_errors:install:migrations"].invoke
    Rake::Task["db:migrate"].invoke

    # Create default admin user if none exists
    if VibeErrors::Owner.count.zero?
      puts "Creating default admin user..."
      VibeErrors::Owner.create!(
        name: "Admin User",
        email: "admin@example.com",
        active: true
      )
    end

    puts "VibeErrors setup complete!"
    puts "Visit /vibe_errors to access the dashboard."
  end

  desc "Clean up old resolved errors based on retention policy"
  task cleanup: :environment do
    retention_days = VibeErrors.configuration.retain_resolved_errors_for
    cutoff_date = retention_days.days.ago

    puts "Cleaning up resolved errors older than #{retention_days} days..."

    old_errors = VibeErrors::Error.where(status: "resolved")
      .where("resolved_at < ?", cutoff_date)

    deleted_count = old_errors.count
    old_errors.destroy_all

    puts "Deleted #{deleted_count} old resolved errors."

    # Clean up old messages
    message_retention_days = VibeErrors.configuration.retain_messages_for
    message_cutoff_date = message_retention_days.days.ago

    puts "Cleaning up messages older than #{message_retention_days} days..."

    old_messages = VibeErrors::Message.where("created_at < ?", message_cutoff_date)
    deleted_messages_count = old_messages.count
    old_messages.destroy_all

    puts "Deleted #{deleted_messages_count} old messages."
    puts "Cleanup complete!"
  end

  desc "Generate sample data for testing"
  task sample_data: :environment do
    puts "Generating sample data..."

    # Create sample owners
    owners = []
    5.times do |i|
      owner = VibeErrors::Owner.create!(
        name: "Developer #{i + 1}",
        email: "dev#{i + 1}@example.com",
        first_name: "Dev",
        last_name: (i + 1).to_s,
        github_username: "dev#{i + 1}",
        active: true
      )
      owners << owner
    end

    # Create sample teams
    teams = []
    %w[Backend Frontend DevOps QA].each do |team_name|
      team = VibeErrors::Team.create!(
        name: "#{team_name} Team",
        slug: team_name.downcase,
        description: "#{team_name} development team",
        active: true
      )
      teams << team
    end

    # Create sample projects
    projects = []
    %w[WebApp API MobileApp Dashboard].each do |project_name|
      project = VibeErrors::Project.create!(
        name: project_name,
        slug: project_name.downcase,
        description: "#{project_name} project",
        environment: "production",
        active: true
      )
      projects << project
    end

    # Create sample tags
    tags = []
    %w[database api authentication payment performance security].each do |tag_name|
      tag = VibeErrors::Tag.create!(
        name: tag_name,
        color: "##{SecureRandom.hex(3)}"
      )
      tags << tag
    end

    # Create sample errors
    20.times do |i|
      error = VibeErrors::Error.create!(
        message: "Sample error #{i + 1}: #{["Database connection failed", "API timeout", "Authentication error", "Payment processing failed"].sample}",
        exception_class: ["ActiveRecord::ConnectionTimeoutError", "Net::TimeoutError", "AuthenticationError", "PaymentError"].sample,
        severity: ["low", "medium", "high", "critical"].sample,
        status: ["new", "in_progress", "resolved", "ignored"].sample,
        priority: ["low", "medium", "high", "critical"].sample,
        occurred_at: rand(30.days).seconds.ago,
        owner: owners.sample,
        team: teams.sample,
        project: projects.sample,
        stack_trace: "app/controllers/application_controller.rb:#{rand(100)}\napp/models/user.rb:#{rand(50)}\napp/services/payment_service.rb:#{rand(200)}"
      )

      # Add random tags
      error.tags << tags.sample(rand(3))
    end

    # Create sample messages
    50.times do |i|
      message = VibeErrors::Message.create!(
        content: "Sample message #{i + 1}: #{["User logged in", "Payment processed", "Email sent", "Background job completed"].sample}",
        severity: ["info", "warning", "error", "critical"].sample,
        message_type: ["log", "debug", "info", "warning", "error"].sample,
        owner: owners.sample,
        team: teams.sample,
        project: projects.sample
      )

      # Add random tags
      message.tags << tags.sample(rand(2))
    end

    puts "Sample data generated successfully!"
    puts "- #{owners.count} owners created"
    puts "- #{teams.count} teams created"
    puts "- #{projects.count} projects created"
    puts "- #{tags.count} tags created"
    puts "- 20 errors created"
    puts "- 50 messages created"
  end

  desc "Display VibeErrors statistics"
  task stats: :environment do
    puts "VibeErrors Statistics:"
    puts "====================="
    puts "Total Errors: #{VibeErrors::Error.count}"
    puts "  - New: #{VibeErrors::Error.where(status: "new").count}"
    puts "  - In Progress: #{VibeErrors::Error.where(status: "in_progress").count}"
    puts "  - Resolved: #{VibeErrors::Error.where(status: "resolved").count}"
    puts "  - Ignored: #{VibeErrors::Error.where(status: "ignored").count}"
    puts ""
    puts "By Severity:"
    VibeErrors::Error.group(:severity).count.each do |severity, count|
      puts "  - #{severity.capitalize}: #{count}"
    end
    puts ""
    puts "Total Messages: #{VibeErrors::Message.count}"
    puts "Total Tags: #{VibeErrors::Tag.count}"
    puts "Total Owners: #{VibeErrors::Owner.count}"
    puts "Total Teams: #{VibeErrors::Team.count}"
    puts "Total Projects: #{VibeErrors::Project.count}"
    puts ""
    puts "Recent Activity (last 24 hours):"
    puts "  - Errors: #{VibeErrors::Error.where("created_at > ?", 24.hours.ago).count}"
    puts "  - Messages: #{VibeErrors::Message.where("created_at > ?", 24.hours.ago).count}"
  end

  desc "Export errors to CSV"
  task export_errors: :environment do
    require "csv"

    filename = "vibe_errors_#{Date.current.strftime("%Y%m%d")}.csv"

    CSV.open(filename, "wb") do |csv|
      csv << ["ID", "Message", "Severity", "Status", "Priority", "Owner", "Team", "Project", "Created At"]

      VibeErrors::Error.includes(:owner, :team, :project).find_each do |error|
        csv << [
          error.id,
          error.message,
          error.severity,
          error.status,
          error.priority,
          error.owner&.name,
          error.team&.name,
          error.project&.name,
          error.created_at
        ]
      end
    end

    puts "Errors exported to #{filename}"
  end
end
