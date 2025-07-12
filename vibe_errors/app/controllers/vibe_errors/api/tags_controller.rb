module VibeErrors
  module Api
    class TagsController < BaseController
      before_action :set_tag, only: [:show, :update, :destroy]

      def index
        @tags = Tag.all
        @tags = @tags.by_name(params[:q]) if params[:q].present?
        @tags = @tags.page(pagination_params[:page]).per(pagination_params[:per_page])

        render json: {
          tags: @tags.map { |tag| tag_json(tag) },
          meta: pagination_meta(@tags)
        }
      end

      def show
        render json: {tag: tag_json(@tag, detailed: true)}
      end

      def create
        @tag = Tag.new(tag_params)

        if @tag.save
          render json: {tag: tag_json(@tag, detailed: true)}, status: :created
        else
          render json: {
            error: "Failed to create tag",
            errors: @tag.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      def update
        if @tag.update(tag_params)
          render json: {tag: tag_json(@tag, detailed: true)}
        else
          render json: {
            error: "Failed to update tag",
            errors: @tag.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      def destroy
        @tag.destroy
        head :no_content
      end

      def popular
        @tags = Tag.popular.limit(params[:limit] || 20)
        render json: {
          tags: @tags.map { |tag| tag_json(tag).merge(usage_count: tag.usage_count) }
        }
      end

      private

      def set_tag
        @tag = Tag.find(params[:id])
      end

      def tag_params
        params.require(:tag).permit(:name, :color, :description)
      end

      def tag_json(tag, detailed: false)
        json = {
          id: tag.id,
          name: tag.name,
          color: tag.color,
          created_at: tag.created_at,
          updated_at: tag.updated_at
        }

        if detailed
          json.merge!(
            description: tag.description,
            usage_count: tag.usage_count,
            error_count: tag.error_count,
            message_count: tag.message_count
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
