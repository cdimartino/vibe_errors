module VibeErrors
  module Api
    class BaseController < ApplicationController
      before_action :set_default_format

      rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
      rescue_from ActiveRecord::RecordInvalid, with: :record_invalid
      rescue_from StandardError, with: :internal_server_error

      private

      def set_default_format
        request.format = :json if request.format.html?
      end

      def record_not_found(exception)
        render json: {
          error: "Record not found",
          message: exception.message
        }, status: :not_found
      end

      def record_invalid(exception)
        render json: {
          error: "Validation failed",
          message: exception.message,
          errors: exception.record.errors.full_messages
        }, status: :unprocessable_entity
      end

      def internal_server_error(exception)
        render json: {
          error: "Internal server error",
          message: exception.message
        }, status: :internal_server_error
      end

      def pagination_params
        {
          page: params[:page] || 1,
          per_page: [params[:per_page]&.to_i || 25, 100].min
        }
      end

      def search_params
        params.permit(:q, :severity, :status, :priority, :owner_id, :team_id, :project_id, :tag)
      end
    end
  end
end
