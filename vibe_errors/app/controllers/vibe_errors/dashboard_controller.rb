module VibeErrors
  class DashboardController < ApplicationController
    def index
      @stats = {
        total_errors: Error.count,
        unresolved_errors: Error.where.not(status: "resolved").count,
        critical_errors: Error.where(severity: "critical").count,
        errors_today: Error.where(created_at: Date.current.beginning_of_day..Date.current.end_of_day).count,
        total_messages: Message.count,
        messages_today: Message.where(created_at: Date.current.beginning_of_day..Date.current.end_of_day).count
      }

      @recent_errors = Error.recent.includes(:owner, :team, :project, :tags).limit(10)
      @critical_errors = Error.where(severity: "critical").recent.includes(:owner, :team, :project, :tags).limit(5)
      @unresolved_errors = Error.where.not(status: "resolved").recent.includes(:owner, :team, :project, :tags).limit(5)

      @error_stats_by_severity = Error.group(:severity).count
      @error_stats_by_status = Error.group(:status).count
      @error_stats_by_day = Error.group("DATE(created_at)").count.transform_keys(&:to_s)

      @popular_tags = Tag.popular.limit(10)
      @active_owners = Owner.joins(:errors).group(:id).order("COUNT(vibe_errors_errors.id) DESC").limit(5)
    end
  end
end
