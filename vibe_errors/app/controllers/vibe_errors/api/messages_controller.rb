module VibeErrors
  module Api
    class MessagesController < BaseController
      before_action :set_message, only: [:show, :update, :destroy]

      def index
        @messages = Message.all
        @messages = apply_filters(@messages)
        @messages = @messages.includes(:owner, :team, :project, :tags)
        @messages = @messages.page(pagination_params[:page]).per(pagination_params[:per_page])

        render json: {
          messages: @messages.map { |message| message_json(message) },
          meta: pagination_meta(@messages)
        }
      end

      def show
        render json: {message: message_json(@message, detailed: true)}
      end

      def create
        @message = Message.new(message_params)

        if @message.save
          assign_tags_if_provided
          render json: {message: message_json(@message, detailed: true)}, status: :created
        else
          render json: {
            error: "Failed to create message",
            errors: @message.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      def update
        if @message.update(message_params)
          assign_tags_if_provided
          render json: {message: message_json(@message, detailed: true)}
        else
          render json: {
            error: "Failed to update message",
            errors: @message.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      def destroy
        @message.destroy
        head :no_content
      end

      def create_from_content
        content = params.require(:content)
        options = create_from_content_params.to_h.symbolize_keys

        begin
          @message = Message.create_from_message(content, options)

          if @message.persisted?
            assign_tags_if_provided
            render json: {message: message_json(@message, detailed: true)}, status: :created
          else
            render json: {
              error: "Failed to create message from content",
              errors: @message.errors.full_messages
            }, status: :unprocessable_entity
          end
        rescue => e
          render json: {
            error: "Failed to process message content",
            message: e.message
          }, status: :bad_request
        end
      end

      def add_tag
        @message = Message.find(params[:id])
        tag_name = params[:tag_name]

        @message.add_tag(tag_name)
        render json: {message: message_json(@message, detailed: true)}
      end

      def remove_tag
        @message = Message.find(params[:id])
        tag_name = params[:tag_name]

        @message.remove_tag(tag_name)
        render json: {message: message_json(@message, detailed: true)}
      end

      private

      def set_message
        @message = Message.find(params[:id])
      end

      def message_params
        params.require(:message).permit(
          :content, :severity, :message_type, :context, :metadata,
          :owner_id, :team_id, :project_id
        )
      end

      def create_from_content_params
        params.permit(:severity, :message_type, :context, :metadata, :owner_id, :team_id, :project_id)
      end

      def apply_filters(messages)
        search_params.each do |key, value|
          next if value.blank?

          case key
          when "q"
            messages = messages.where("content ILIKE ? OR context ILIKE ?",
              "%#{value}%", "%#{value}%")
          when "severity"
            messages = messages.by_severity(value)
          when "message_type"
            messages = messages.by_type(value)
          when "owner_id"
            messages = messages.by_owner(value)
          when "team_id"
            messages = messages.by_team(value)
          when "project_id"
            messages = messages.by_project(value)
          when "tag"
            messages = messages.joins(:tags).where("vibe_errors_tags.name = ?", value)
          end
        end

        messages.recent
      end

      def assign_tags_if_provided
        return unless params[:tags].present?

        @message.tags.clear
        params[:tags].each do |tag_name|
          @message.add_tag(tag_name)
        end
      end

      def message_json(message, detailed: false)
        json = {
          id: message.id,
          content: message.content,
          severity: message.severity,
          message_type: message.message_type,
          created_at: message.created_at,
          updated_at: message.updated_at,
          owner: message.owner ? {id: message.owner.id, name: message.owner.name} : nil,
          team: message.team ? {id: message.team.id, name: message.team.name} : nil,
          project: message.project ? {id: message.project.id, name: message.project.name} : nil,
          tags: message.tags.map { |tag| {id: tag.id, name: tag.name} }
        }

        if detailed
          json[:context] = message.context
          json[:metadata] = message.metadata
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
