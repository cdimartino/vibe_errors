module VibeErrors
  class MessagesController < ApplicationController
    before_action :set_message, only: [:show, :edit, :update, :destroy, :add_tag, :remove_tag]

    def index
      @messages = Message.all
      @messages = apply_filters(@messages)
      @messages = @messages.includes(:owner, :team, :project, :tags)
      @messages = @messages.page(params[:page]).per(params[:per_page] || 25)

      @severities = Message.distinct.pluck(:severity).compact
      @message_types = Message.distinct.pluck(:message_type).compact
      @owners = Owner.all
      @teams = Team.all
      @projects = Project.all
      @tags = Tag.all
    end

    def show
      @similar_messages = Message.where(message_type: @message.message_type)
        .where.not(id: @message.id)
        .limit(5)
      @available_owners = Owner.all
      @available_teams = Team.all
      @available_projects = Project.all
    end

    def new
      @message = Message.new
      @owners = Owner.all
      @teams = Team.all
      @projects = Project.all
    end

    def create
      @message = Message.new(message_params)

      if @message.save
        handle_tags
        redirect_to @message, notice: "Message was successfully created."
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
      if @message.update(message_params)
        handle_tags
        redirect_to @message, notice: "Message was successfully updated."
      else
        @owners = Owner.all
        @teams = Team.all
        @projects = Project.all
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @message.destroy
      redirect_to messages_url, notice: "Message was successfully deleted."
    end

    def add_tag
      tag_name = params[:tag_name]

      if tag_name.present?
        @message.add_tag(tag_name)
        redirect_to @message, notice: "Tag was successfully added."
      else
        redirect_to @message, alert: "Tag name cannot be blank."
      end
    end

    def remove_tag
      tag_name = params[:tag_name]

      @message.remove_tag(tag_name)
      redirect_to @message, notice: "Tag was successfully removed."
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

    def apply_filters(messages)
      return messages unless params[:filter].present?

      filter_params = params[:filter]

      messages = messages.where("content ILIKE ?", "%#{filter_params[:q]}%") if filter_params[:q].present?
      messages = messages.by_severity(filter_params[:severity]) if filter_params[:severity].present?
      messages = messages.by_type(filter_params[:message_type]) if filter_params[:message_type].present?
      messages = messages.by_owner(filter_params[:owner_id]) if filter_params[:owner_id].present?
      messages = messages.by_team(filter_params[:team_id]) if filter_params[:team_id].present?
      messages = messages.by_project(filter_params[:project_id]) if filter_params[:project_id].present?

      if filter_params[:tag].present?
        messages = messages.joins(:tags).where("vibe_errors_tags.name = ?", filter_params[:tag])
      end

      messages.recent
    end

    def handle_tags
      return unless params[:tags].present?

      @message.tags.clear
      tag_names = params[:tags].split(",").map(&:strip).reject(&:blank?)
      tag_names.each { |tag_name| @message.add_tag(tag_name) }
    end
  end
end
