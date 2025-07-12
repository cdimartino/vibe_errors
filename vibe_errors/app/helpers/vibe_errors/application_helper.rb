module VibeErrors
  module ApplicationHelper
    def severity_color(severity)
      case severity&.to_s
      when "low"
        "info"
      when "medium"
        "warning"
      when "high"
        "danger"
      when "critical"
        "dark"
      else
        "secondary"
      end
    end

    def status_color(status)
      case status&.to_s
      when "new"
        "primary"
      when "in_progress"
        "warning"
      when "resolved"
        "success"
      when "ignored"
        "secondary"
      else
        "light"
      end
    end

    def priority_color(priority)
      case priority&.to_s
      when "low"
        "info"
      when "medium"
        "warning"
      when "high"
        "danger"
      when "critical"
        "dark"
      else
        "secondary"
      end
    end

    def message_severity_color(severity)
      case severity&.to_s
      when "info"
        "info"
      when "warning"
        "warning"
      when "error"
        "danger"
      when "critical"
        "dark"
      else
        "secondary"
      end
    end

    def format_stack_trace(stack_trace)
      return "" unless stack_trace.present?

      stack_trace.split("\n").map do |line|
        if line.include?("/app/")
          content_tag(:div, line, class: "text-primary")
        elsif line.include?("/gems/")
          content_tag(:div, line, class: "text-muted")
        else
          content_tag(:div, line)
        end
      end.join.html_safe
    end

    def truncate_with_tooltip(text, length: 50)
      if text.length > length
        content_tag(:span, truncate(text, length: length),
          title: text, data: {toggle: "tooltip"})
      else
        text
      end
    end

    def error_icon(severity)
      case severity&.to_s
      when "critical"
        "⚠️"
      when "high"
        "🔴"
      when "medium"
        "🟡"
      when "low"
        "🟢"
      else
        "ℹ️"
      end
    end

    def time_ago_with_tooltip(time)
      content_tag(:span, time_ago_in_words(time) + " ago",
        title: time.strftime("%Y-%m-%d %H:%M:%S"),
        data: {toggle: "tooltip"})
    end

    def render_metadata(metadata)
      return "" unless metadata.present?

      content_tag(:pre, JSON.pretty_generate(metadata), class: "bg-light p-2 rounded")
    end

    def tag_link(tag, css_class: "badge bg-secondary")
      link_to tag.name, tag_path(tag), class: "#{css_class} text-decoration-none"
    end

    def owner_link(owner)
      return "Unassigned" unless owner

      link_to owner.name, owner_path(owner), class: "text-decoration-none"
    end

    def team_link(team)
      return "No Team" unless team

      link_to team.name, team_path(team), class: "text-decoration-none"
    end

    def project_link(project)
      return "No Project" unless project

      link_to project.name, project_path(project), class: "text-decoration-none"
    end
  end
end
