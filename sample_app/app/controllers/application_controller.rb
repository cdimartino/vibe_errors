class ApplicationController < ActionController::Base
  def index
    @stats = {
      total_errors: VibeErrors::Error.count,
      total_messages: VibeErrors::Message.count,
      recent_errors: VibeErrors::Error.recent.limit(5)
    }
  end

  def simulate_error
    case params[:type]
    when 'database'
      raise ActiveRecord::ConnectionTimeoutError, "Database connection timeout"
    when 'api'
      raise Net::TimeoutError, "External API timeout"
    when 'authentication'
      raise SecurityError, "Authentication failed"
    else
      raise StandardError, "Generic application error"
    end
  rescue => e
    # Capture the error using VibeErrors
    VibeErrors.capture_exception(e, {
      severity: 'medium',
      auto_assign_owner: true,
      context: {
        controller: 'application',
        action: 'simulate_error',
        error_type: params[:type]
      }.to_json
    })
    
    redirect_to root_path, alert: "Error simulated and captured: #{e.message}"
  end

  def log_message
    message_type = params[:message_type] || 'info'
    content = params[:content] || "Sample #{message_type} message from application"
    
    case message_type
    when 'error'
      VibeErrors.log_error(content)
    when 'warning'
      VibeErrors.log_warning(content)
    else
      VibeErrors.log_info(content)
    end
    
    redirect_to root_path, notice: "#{message_type.capitalize} message logged successfully"
  end
end
