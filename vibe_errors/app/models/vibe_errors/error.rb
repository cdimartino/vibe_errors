module VibeErrors
  class Error < ApplicationRecord
    self.table_name = "vibe_errors_errors"

    has_many :error_tags, dependent: :destroy
    has_many :tags, through: :error_tags

    belongs_to :owner, class_name: "VibeErrors::Owner", optional: true
    belongs_to :team, class_name: "VibeErrors::Team", optional: true
    belongs_to :project, class_name: "VibeErrors::Project", optional: true

    validates :message, presence: true
    validates :severity, presence: true, inclusion: {in: %w[low medium high critical]}
    validates :status, presence: true, inclusion: {in: %w[new in_progress resolved ignored]}
    validates :priority, inclusion: {in: %w[low medium high critical]}, allow_nil: true

    scope :by_severity, ->(severity) { where(severity: severity) }
    scope :by_status, ->(status) { where(status: status) }
    scope :by_priority, ->(priority) { where(priority: priority) }
    scope :by_owner, ->(owner_id) { where(owner_id: owner_id) }
    scope :by_team, ->(team_id) { where(team_id: team_id) }
    scope :by_project, ->(project_id) { where(project_id: project_id) }
    scope :recent, -> { order(created_at: :desc) }

    def self.from_exception(exception, options = {})
      error = new(
        message: exception.message,
        exception_class: exception.class.name,
        stack_trace: exception.backtrace&.join("\n"),
        location: extract_location_from_backtrace(exception.backtrace),
        severity: options[:severity] || "medium",
        status: options[:status] || "new",
        priority: options[:priority],
        occurred_at: Time.current
      )

      error.assign_owner_from_stack_trace if options[:auto_assign_owner]
      error.save!
      error
    end

    def self.extract_location_from_backtrace(backtrace)
      return nil unless backtrace&.any?

      # Get the first line that's not from gems or system libraries
      app_line = backtrace.find { |line| !line.include?("/gems/") && !line.include?("/ruby/") }
      app_line || backtrace.first
    end

    def assign_owner_from_stack_trace
      return unless stack_trace.present?

      service = OwnershipAssignmentService.new(self)
      assigned_owner = service.assign_owner

      if assigned_owner
        Rails.logger.info("Auto-assigned owner #{assigned_owner.name} to error #{id}")
        assigned_owner
      else
        Rails.logger.info("Could not auto-assign owner for error #{id}")
        nil
      end
    end

    def add_tag(tag_name)
      tag = Tag.find_or_create_by(name: tag_name.downcase)
      tags << tag unless tags.include?(tag)
    end

    def remove_tag(tag_name)
      tag = tags.find_by(name: tag_name.downcase)
      tags.delete(tag) if tag
    end

    def resolved?
      status == "resolved"
    end

    def critical?
      severity == "critical"
    end

    def high_priority?
      priority == "high" || priority == "critical"
    end

    private

    def find_owner_by_file_path(file_path)
      # This is a placeholder implementation
      # In a real scenario, you'd integrate with version control systems
      # or maintain a mapping of file paths to owners
      Owner.find_by(name: "Default Owner")
    end
  end
end
