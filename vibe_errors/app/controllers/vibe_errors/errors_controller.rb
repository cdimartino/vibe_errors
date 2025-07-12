module VibeErrors
  class ErrorsController < ApplicationController
    before_action :set_error, only: [:show, :edit, :update, :destroy, :resolve, :assign_owner, :add_tag, :remove_tag]

    def index
      @errors = Error.all
      @errors = apply_filters(@errors)
      @errors = @errors.includes(:owner, :team, :project, :tags)
      @errors = @errors.page(params[:page]).per(params[:per_page] || 25)

      @severities = Error.distinct.pluck(:severity).compact
      @statuses = Error.distinct.pluck(:status).compact
      @priorities = Error.distinct.pluck(:priority).compact
      @owners = Owner.all
      @teams = Team.all
      @projects = Project.all
      @tags = Tag.all
    end

    def show
      @similar_errors = Error.where(exception_class: @error.exception_class)
        .where.not(id: @error.id)
        .limit(5)
      @available_owners = Owner.all
      @available_teams = Team.all
      @available_projects = Project.all
    end

    def new
      @error = Error.new
      @owners = Owner.all
      @teams = Team.all
      @projects = Project.all
    end

    def create
      @error = Error.new(error_params)

      if @error.save
        handle_tags
        redirect_to @error, notice: "Error was successfully created."
      else
        @owners = Owner.all
        @teams = Team.all
        @projects = Project.all
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @owners = Owner.all
      @teams = Team.all
      @projects = Project.all
    end

    def update
      if @error.update(error_params)
        handle_tags
        redirect_to @error, notice: "Error was successfully updated."
      else
        @owners = Owner.all
        @teams = Team.all
        @projects = Project.all
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @error.destroy
      redirect_to errors_url, notice: "Error was successfully deleted."
    end

    def resolve
      if @error.update(
        status: "resolved",
        resolved_at: Time.current,
        resolution: params[:resolution]
      )
        redirect_to @error, notice: "Error was successfully resolved."
      else
        redirect_to @error, alert: "Failed to resolve error."
      end
    end

    def assign_owner
      owner = Owner.find(params[:owner_id]) if params[:owner_id].present?

      if @error.update(owner: owner)
        redirect_to @error, notice: "Owner was successfully assigned."
      else
        redirect_to @error, alert: "Failed to assign owner."
      end
    end

    def add_tag
      tag_name = params[:tag_name]

      if tag_name.present?
        @error.add_tag(tag_name)
        redirect_to @error, notice: "Tag was successfully added."
      else
        redirect_to @error, alert: "Tag name cannot be blank."
      end
    end

    def remove_tag
      tag_name = params[:tag_name]

      @error.remove_tag(tag_name)
      redirect_to @error, notice: "Tag was successfully removed."
    end

    private

    def set_error
      @error = Error.find(params[:id])
    end

    def error_params
      params.require(:error).permit(
        :message, :exception_class, :stack_trace, :location, :severity, :status,
        :priority, :occurred_at, :resolved_at, :resolution, :context, :metadata,
        :due_date, :owner_id, :team_id, :project_id
      )
    end

    def apply_filters(errors)
      return errors unless params[:filter].present?

      filter_params = params[:filter]

      errors = errors.where("message ILIKE ?", "%#{filter_params[:q]}%") if filter_params[:q].present?
      errors = errors.by_severity(filter_params[:severity]) if filter_params[:severity].present?
      errors = errors.by_status(filter_params[:status]) if filter_params[:status].present?
      errors = errors.by_priority(filter_params[:priority]) if filter_params[:priority].present?
      errors = errors.by_owner(filter_params[:owner_id]) if filter_params[:owner_id].present?
      errors = errors.by_team(filter_params[:team_id]) if filter_params[:team_id].present?
      errors = errors.by_project(filter_params[:project_id]) if filter_params[:project_id].present?

      if filter_params[:tag].present?
        errors = errors.joins(:tags).where("vibe_errors_tags.name = ?", filter_params[:tag])
      end

      errors.recent
    end

    def handle_tags
      return unless params[:tags].present?

      @error.tags.clear
      tag_names = params[:tags].split(",").map(&:strip).reject(&:blank?)
      tag_names.each { |tag_name| @error.add_tag(tag_name) }
    end
  end
end
