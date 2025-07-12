module VibeErrors
  class SearchController < ApplicationController
    def index
      @query = params[:q]
      @filter_type = params[:type] || "all"

      if @query.present?
        @errors = search_errors(@query)
        @messages = search_messages(@query)
        @tags = search_tags(@query)
        @owners = search_owners(@query)
        @teams = search_teams(@query)
        @projects = search_projects(@query)

        @results = case @filter_type
        when "errors"
          @errors
        when "messages"
          @messages
        when "tags"
          @tags
        when "owners"
          @owners
        when "teams"
          @teams
        when "projects"
          @projects
        else
          {
            errors: @errors.limit(10),
            messages: @messages.limit(10),
            tags: @tags.limit(10),
            owners: @owners.limit(10),
            teams: @teams.limit(10),
            projects: @projects.limit(10)
          }
        end
      else
        @results = {}
      end

      @search_stats = {
        errors_count: @errors&.count || 0,
        messages_count: @messages&.count || 0,
        tags_count: @tags&.count || 0,
        owners_count: @owners&.count || 0,
        teams_count: @teams&.count || 0,
        projects_count: @projects&.count || 0
      }
    end

    private

    def search_errors(query)
      Error.where(
        "message ILIKE ? OR exception_class ILIKE ? OR stack_trace ILIKE ? OR location ILIKE ?",
        "%#{query}%", "%#{query}%", "%#{query}%", "%#{query}%"
      ).includes(:owner, :team, :project, :tags)
    end

    def search_messages(query)
      Message.where(
        "content ILIKE ? OR context ILIKE ?",
        "%#{query}%", "%#{query}%"
      ).includes(:owner, :team, :project, :tags)
    end

    def search_tags(query)
      Tag.by_name(query)
    end

    def search_owners(query)
      Owner.where(
        "name ILIKE ? OR email ILIKE ? OR first_name ILIKE ? OR last_name ILIKE ?",
        "%#{query}%", "%#{query}%", "%#{query}%", "%#{query}%"
      )
    end

    def search_teams(query)
      Team.by_name(query)
    end

    def search_projects(query)
      Project.by_name(query)
    end
  end
end
