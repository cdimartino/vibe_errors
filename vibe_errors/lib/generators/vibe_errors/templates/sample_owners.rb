# Sample owners for VibeErrors
# Run with: rails db:seed

if defined?(VibeErrors)
  puts "Creating sample VibeErrors owners..."

  # Create sample owners
  owners = [
    {
      name: "John Doe",
      email: "john.doe@example.com",
      first_name: "John",
      last_name: "Doe",
      github_username: "johndoe",
      active: true
    },
    {
      name: "Jane Smith",
      email: "jane.smith@example.com",
      first_name: "Jane",
      last_name: "Smith",
      github_username: "janesmith",
      active: true
    },
    {
      name: "Bob Johnson",
      email: "bob.johnson@example.com",
      first_name: "Bob",
      last_name: "Johnson",
      github_username: "bobjohnson",
      active: true
    }
  ]

  owners.each do |owner_attrs|
    owner = VibeErrors::Owner.find_or_create_by(email: owner_attrs[:email]) do |o|
      o.assign_attributes(owner_attrs)
    end
    puts "Created owner: #{owner.name}"
  end

  # Create sample teams
  teams = [
    {
      name: "Backend Team",
      slug: "backend",
      description: "Responsible for API and server-side logic",
      active: true
    },
    {
      name: "Frontend Team",
      slug: "frontend",
      description: "Responsible for user interface and client-side logic",
      active: true
    },
    {
      name: "DevOps Team",
      slug: "devops",
      description: "Responsible for infrastructure and deployment",
      active: true
    }
  ]

  teams.each do |team_attrs|
    team = VibeErrors::Team.find_or_create_by(slug: team_attrs[:slug]) do |t|
      t.assign_attributes(team_attrs)
    end
    puts "Created team: #{team.name}"
  end

  # Create sample projects
  projects = [
    {
      name: "Web Application",
      slug: "web-app",
      description: "Main web application",
      environment: "production",
      active: true
    },
    {
      name: "API Service",
      slug: "api-service",
      description: "REST API service",
      environment: "production",
      active: true
    },
    {
      name: "Background Jobs",
      slug: "background-jobs",
      description: "Background job processing",
      environment: "production",
      active: true
    }
  ]

  projects.each do |project_attrs|
    project = VibeErrors::Project.find_or_create_by(slug: project_attrs[:slug]) do |p|
      p.assign_attributes(project_attrs)
    end
    puts "Created project: #{project.name}"
  end

  # Create sample tags
  tags = [
    {name: "database", color: "#007bff"},
    {name: "api", color: "#28a745"},
    {name: "authentication", color: "#ffc107"},
    {name: "payment", color: "#dc3545"},
    {name: "performance", color: "#6f42c1"},
    {name: "security", color: "#fd7e14"}
  ]

  tags.each do |tag_attrs|
    tag = VibeErrors::Tag.find_or_create_by(name: tag_attrs[:name]) do |t|
      t.assign_attributes(tag_attrs)
    end
    puts "Created tag: #{tag.name}"
  end

  puts "Sample data created successfully!"
  puts "You can now visit /vibe_errors to see the dashboard."
end
