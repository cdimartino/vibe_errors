module VibeErrors
  class HealthController < ApplicationController
    skip_before_action :verify_authenticity_token
    
    def index
      health_status = {
        status: "ok",
        timestamp: Time.current.iso8601,
        version: VibeErrors::VERSION,
        rails_version: Rails.version,
        ruby_version: RUBY_VERSION,
        checks: {
          database: database_check,
          cache: cache_check,
          memory: memory_check
        }
      }
      
      if health_status[:checks].values.all? { |check| check[:status] == "ok" }
        render json: health_status, status: :ok
      else
        render json: health_status, status: :service_unavailable
      end
    end
    
    private
    
    def database_check
      begin
        ActiveRecord::Base.connection.execute("SELECT 1")
        Error.count # Test that our models work
        {
          status: "ok",
          message: "Database connection successful"
        }
      rescue => e
        {
          status: "error",
          message: "Database connection failed: #{e.message}"
        }
      end
    end
    
    def cache_check
      begin
        # Test cache if available
        if Rails.cache.respond_to?(:write)
          test_key = "health_check_#{Time.current.to_i}"
          Rails.cache.write(test_key, "test_value", expires_in: 1.minute)
          value = Rails.cache.read(test_key)
          
          if value == "test_value"
            Rails.cache.delete(test_key)
            {
              status: "ok",
              message: "Cache working properly"
            }
          else
            {
              status: "warning",
              message: "Cache read/write mismatch"
            }
          end
        else
          {
            status: "ok",
            message: "Cache not configured"
          }
        end
      rescue => e
        {
          status: "error",
          message: "Cache error: #{e.message}"
        }
      end
    end
    
    def memory_check
      begin
        # Get memory usage if available
        if defined?(GC)
          gc_stats = GC.stat
          {
            status: "ok",
            message: "Memory check completed",
            details: {
              heap_allocated_pages: gc_stats[:heap_allocated_pages],
              heap_free_slots: gc_stats[:heap_free_slots],
              total_allocated_objects: gc_stats[:total_allocated_objects]
            }
          }
        else
          {
            status: "ok",
            message: "Memory stats not available"
          }
        end
      rescue => e
        {
          status: "error",
          message: "Memory check failed: #{e.message}"
        }
      end
    end
  end
end