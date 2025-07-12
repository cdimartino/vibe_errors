module VibeErrors
  class Configuration
    attr_accessor :auto_capture_errors,
      :auto_assign_owners,
      :default_error_severity,
      :default_message_severity,
      :capture_in_environments,
      :ignored_exceptions,
      :notify_on_critical_errors,
      :notification_email,
      :retain_resolved_errors_for,
      :retain_messages_for,
      :default_per_page,
      :max_per_page,
      :authentication_method,
      :current_user_method,
      :authorize_with,
      :before_save_error,
      :after_save_error

    def initialize
      @auto_capture_errors = true
      @auto_assign_owners = true
      @default_error_severity = "medium"
      @default_message_severity = "info"
      @capture_in_environments = %w[development test staging production]
      @ignored_exceptions = [
        "ActionController::RoutingError",
        "ActionController::InvalidAuthenticityToken",
        "ActiveRecord::RecordNotFound"
      ]
      @notify_on_critical_errors = false
      @notification_email = nil
      @retain_resolved_errors_for = 90
      @retain_messages_for = 30
      @default_per_page = 25
      @max_per_page = 100
      @authentication_method = nil
      @current_user_method = nil
      @authorize_with = nil
      @before_save_error = nil
      @after_save_error = nil
    end

    def should_capture_errors?
      auto_capture_errors && capture_in_environments.include?(Rails.env)
    end

    def should_ignore_exception?(exception)
      exception_class = exception.is_a?(Class) ? exception.name : exception.class.name
      ignored_exceptions.include?(exception_class)
    end

    def should_notify_critical_error?
      notify_on_critical_errors && notification_email.present?
    end
  end
end
