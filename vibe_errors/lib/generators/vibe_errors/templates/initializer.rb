VibeErrors.configure do |config|
  # Enable/disable automatic error capturing
  config.auto_capture_errors = true

  # Enable/disable automatic owner assignment from stack traces
  config.auto_assign_owners = true

  # Set default error severity
  config.default_error_severity = "medium"

  # Set default message severity
  config.default_message_severity = "info"

  # Configure which environments to capture errors in
  config.capture_in_environments = %w[development test staging production]

  # Configure which exceptions to ignore
  config.ignored_exceptions = [
    "ActionController::RoutingError",
    "ActionController::InvalidAuthenticityToken",
    "ActiveRecord::RecordNotFound"
  ]

  # Configure error notification settings
  config.notify_on_critical_errors = true
  config.notification_email = "admin@example.com"

  # Configure retention policy (in days)
  config.retain_resolved_errors_for = 90
  config.retain_messages_for = 30

  # Configure pagination
  config.default_per_page = 25
  config.max_per_page = 100

  # Configure authentication (if needed)
  # config.authentication_method = :devise
  # config.current_user_method = :current_user

  # Configure authorization (if needed)
  # config.authorize_with = :cancancan

  # Configure custom error processing
  # config.before_save_error = ->(error) { puts "Saving error: #{error.message}" }
  # config.after_save_error = ->(error) { puts "Saved error: #{error.id}" }
end
