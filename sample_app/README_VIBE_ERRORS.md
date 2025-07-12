# VibeErrors Sample Application

This is a sample Rails application that demonstrates the VibeErrors engine functionality.

## Setup

1. Install dependencies:
```bash
bundle install
```

2. Setup the database and install VibeErrors:
```bash
rails db:setup
rails generate vibe_errors:install
rails db:migrate
```

3. Create sample data (optional):
```bash
rake vibe_errors:sample_data
```

4. Start the server:
```bash
rails server
```

5. Visit the application:
- Main app: http://localhost:3000
- VibeErrors Dashboard: http://localhost:3000/vibe_errors

## Features Demonstrated

### Error Simulation
The sample app includes buttons to simulate different types of errors:
- Database connection errors
- API timeout errors
- Authentication errors
- Generic application errors

Each simulated error is automatically captured by VibeErrors with:
- Proper severity levels
- Stack trace information
- Contextual metadata
- Auto-assignment attempts

### Message Logging
The app demonstrates different message logging capabilities:
- Info messages
- Warning messages
- Error messages
- Custom message content

### VibeErrors Integration
The sample app shows how to:
- Mount the VibeErrors engine
- Configure error capturing
- Use the API for manual error/message creation
- Integrate with existing Rails error handling

## API Examples

### Capturing Exceptions Manually
```ruby
begin
  # Some risky operation
  risky_operation
rescue => e
  VibeErrors.capture_exception(e, {
    severity: 'high',
    auto_assign_owner: true,
    context: { controller: 'users', action: 'create' }.to_json
  })
end
```

### Logging Messages
```ruby
# Log different message types
VibeErrors.log_info("User login successful")
VibeErrors.log_warning("High memory usage detected")
VibeErrors.log_error("Payment processing failed")

# Log with additional context
VibeErrors.capture_message("Custom message", {
  severity: 'warning',
  message_type: 'audit',
  context: 'user_action',
  metadata: { user_id: 123, action: 'data_export' }
})
```

### Using the API Directly
```bash
# Create error via API
curl -X POST http://localhost:3000/vibe_errors/api/errors \
  -H "Content-Type: application/json" \
  -d '{
    "error": {
      "message": "API created error",
      "severity": "medium",
      "status": "new"
    }
  }'

# Create message via API
curl -X POST http://localhost:3000/vibe_errors/api/messages \
  -H "Content-Type: application/json" \
  -d '{
    "message": {
      "content": "API created message",
      "severity": "info",
      "message_type": "log"
    }
  }'
```

## Dashboard Features

The VibeErrors dashboard provides:

1. **Overview Dashboard**: Statistics and recent activity
2. **Error Management**: Browse, filter, and manage errors
3. **Message Tracking**: View and search logged messages
4. **Search Functionality**: Global search across all data
5. **Tag Management**: Organize errors and messages with tags
6. **Owner Assignment**: Assign errors to team members
7. **Team & Project Organization**: Group errors by teams and projects

## Testing the Integration

1. **Simulate Errors**: Click the error simulation buttons on the homepage
2. **Check Dashboard**: Visit `/vibe_errors` to see captured errors
3. **Test Filtering**: Use the search and filter features
4. **Assign Owners**: Try assigning errors to different owners
5. **Add Tags**: Tag errors for better organization
6. **Test API**: Use the curl examples above

## Configuration

The sample app uses default VibeErrors configuration. To customize:

```ruby
# config/initializers/vibe_errors.rb
VibeErrors.configure do |config|
  config.auto_capture_errors = true
  config.auto_assign_owners = true
  config.default_error_severity = "medium"
  # ... other configuration options
end
```

## Rake Tasks

Available VibeErrors rake tasks:

```bash
# View statistics
rake vibe_errors:stats

# Generate sample data
rake vibe_errors:sample_data

# Clean up old data
rake vibe_errors:cleanup

# Export errors to CSV
rake vibe_errors:export_errors
```

This sample application serves as a complete working example of VibeErrors integration and demonstrates all the key features of the engine.