module VibeErrorsIntegration
  extend ActiveSupport::Concern

  included do
    # Automatically capture exceptions in controllers
    rescue_from StandardError, with: :handle_error_with_vibe_errors if Rails.env.production?

    # In development, you might want to see the full error trace
    # rescue_from StandardError, with: :handle_error_with_vibe_errors unless Rails.env.development?
  end

  private

  def handle_error_with_vibe_errors(exception)
    # Create error record
    error = VibeErrors::Error.from_exception(exception, {
      severity: determine_error_severity(exception),
      auto_assign_owner: true,
      context: gather_error_context,
      metadata: gather_error_metadata
    })

    # Log the error
    Rails.logger.error("VibeErrors: Created error ##{error.id} - #{exception.message}")

    # Notify if critical
    notify_critical_error(error) if error.critical?

    # Re-raise the exception to maintain normal Rails error handling
    raise exception
  end

  def determine_error_severity(exception)
    case exception
    when ActiveRecord::RecordNotFound
      "low"
    when ArgumentError, TypeError
      "medium"
    when SecurityError, SystemExit
      "critical"
    else
      "medium"
    end
  end

  def gather_error_context
    {
      controller: controller_name,
      action: action_name,
      user_agent: request.user_agent,
      ip_address: request.remote_ip,
      url: request.url,
      method: request.method,
      referrer: request.referer,
      user_id: current_user&.id
    }.compact.to_json
  end

  def gather_error_metadata
    {
      params: params.to_unsafe_h.except(:password, :password_confirmation),
      session_id: session.id,
      request_id: request.uuid,
      timestamp: Time.current.iso8601,
      rails_env: Rails.env
    }
  end

  def notify_critical_error(error)
    # Implement your notification logic here
    # For example, send email, Slack notification, PagerDuty alert, etc.
    # ErrorNotificationJob.perform_later(error) if defined?(ErrorNotificationJob)
  end
end
