module VibeErrors
  module Api
    class ErrorsController < BaseController
      before_action :set_error, only: [:show, :update, :destroy]

      def index
        @errors = Error.all
        @errors = apply_filters(@errors)
        @errors = @errors.includes(:owner, :team, :project, :tags)
        @errors = @errors.page(pagination_params[:page]).per(pagination_params[:per_page])

        render json: {
          errors: @errors.map { |error| error_json(error) },
          meta: pagination_meta(@errors)
        }
      end

      def show
        render json: {error: error_json(@error, detailed: true)}
      end

      def create
        @error = Error.new(error_params)

        if @error.save
          assign_tags_if_provided
          render json: {error: error_json(@error, detailed: true)}, status: :created
        else
          render json: {
            error: "Failed to create error",
            errors: @error.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      def update
        if @error.update(error_params)
          assign_tags_if_provided
          render json: {error: error_json(@error, detailed: true)}
        else
          render json: {
            error: "Failed to update error",
            errors: @error.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      def destroy
        @error.destroy
        head :no_content
      end

      def create_from_exception
        exception_data = params.require(:exception)

        begin
          # Create a mock exception object if raw data is provided
          exception = if exception_data.is_a?(Hash)
            create_exception_from_hash(exception_data)
          else
            exception_data
          end

          @error = Error.from_exception(exception, create_from_exception_params)

          if @error.persisted?
            assign_tags_if_provided
            render json: {error: error_json(@error, detailed: true)}, status: :created
          else
            render json: {
              error: "Failed to create error from exception",
              errors: @error.errors.full_messages
            }, status: :unprocessable_entity
          end
        rescue => e
          render json: {
            error: "Failed to process exception",
            message: e.message
          }, status: :bad_request
        end
      end

      def resolve
        @error = Error.find(params[:id])

        if @error.update(
          status: "resolved",
          resolved_at: Time.current,
          resolution: params[:resolution]
        )
          render json: {error: error_json(@error, detailed: true)}
        else
          render json: {
            error: "Failed to resolve error",
            errors: @error.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      def assign_owner
        @error = Error.find(params[:id])
        owner = Owner.find(params[:owner_id])

        if @error.update(owner: owner)
          render json: {error: error_json(@error, detailed: true)}
        else
          render json: {
            error: "Failed to assign owner",
            errors: @error.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      def add_tag
        @error = Error.find(params[:id])
        tag_name = params[:tag_name]

        @error.add_tag(tag_name)
        render json: {error: error_json(@error, detailed: true)}
      end

      def remove_tag
        @error = Error.find(params[:id])
        tag_name = params[:tag_name]

        @error.remove_tag(tag_name)
        render json: {error: error_json(@error, detailed: true)}
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

      def create_from_exception_params
        params.permit(:severity, :status, :priority, :auto_assign_owner, :owner_id, :team_id, :project_id)
      end

      def apply_filters(errors)
        search_params.each do |key, value|
          next if value.blank?

          case key
          when "q"
            errors = errors.where("message ILIKE ? OR exception_class ILIKE ? OR stack_trace ILIKE ?",
              "%#{value}%", "%#{value}%", "%#{value}%")
          when "severity"
            errors = errors.by_severity(value)
          when "status"
            errors = errors.by_status(value)
          when "priority"
            errors = errors.by_priority(value)
          when "owner_id"
            errors = errors.by_owner(value)
          when "team_id"
            errors = errors.by_team(value)
          when "project_id"
            errors = errors.by_project(value)
          when "tag"
            errors = errors.joins(:tags).where("vibe_errors_tags.name = ?", value)
          end
        end

        errors.recent
      end

      def assign_tags_if_provided
        return unless params[:tags].present?

        @error.tags.clear
        params[:tags].each do |tag_name|
          @error.add_tag(tag_name)
        end
      end

      def create_exception_from_hash(data)
        exception_class = data[:exception_class]&.constantize || StandardError
        exception = exception_class.new(data[:message])
        exception.set_backtrace(data[:stack_trace]&.split("\n") || [])
        exception
      end

      def error_json(error, detailed: false)
        json = {
          id: error.id,
          message: error.message,
          exception_class: error.exception_class,
          severity: error.severity,
          status: error.status,
          priority: error.priority,
          location: error.location,
          occurred_at: error.occurred_at,
          resolved_at: error.resolved_at,
          occurrence_count: error.occurrence_count,
          created_at: error.created_at,
          updated_at: error.updated_at,
          owner: error.owner ? {id: error.owner.id, name: error.owner.name} : nil,
          team: error.team ? {id: error.team.id, name: error.team.name} : nil,
          project: error.project ? {id: error.project.id, name: error.project.name} : nil,
          tags: error.tags.map { |tag| {id: tag.id, name: tag.name} }
        }

        if detailed
          json.merge!(
            stack_trace: error.stack_trace,
            context: error.context,
            metadata: error.metadata,
            resolution: error.resolution,
            due_date: error.due_date,
            checksum: error.checksum
          )
        end

        json
      end

      def pagination_meta(collection)
        {
          current_page: collection.current_page,
          per_page: collection.limit_value,
          total_pages: collection.total_pages,
          total_count: collection.total_count
        }
      end
    end
  end
end
