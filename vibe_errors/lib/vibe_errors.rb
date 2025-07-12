require "vibe_errors/version"
require "vibe_errors/engine"
require "vibe_errors/configuration"

module VibeErrors
  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
  end

  def self.reset_configuration!
    @configuration = Configuration.new
  end

  # Convenience methods for common operations
  def self.capture_exception(exception, options = {})
    return unless configuration.should_capture_errors?
    return if configuration.should_ignore_exception?(exception)

    Error.from_exception(exception, options)
  end

  def self.capture_message(content, options = {})
    return unless configuration.should_capture_errors?

    Message.create_from_message(content, options)
  end

  def self.log_error(message, options = {})
    capture_message(message, options.merge(severity: "error", message_type: "error"))
  end

  def self.log_warning(message, options = {})
    capture_message(message, options.merge(severity: "warning", message_type: "warning"))
  end

  def self.log_info(message, options = {})
    capture_message(message, options.merge(severity: "info", message_type: "info"))
  end
end
