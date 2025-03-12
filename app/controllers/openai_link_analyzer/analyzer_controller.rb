# frozen_string_literal: true

module OpenaiLinkAnalyzer
  class AnalyzerController < ::ApplicationController
    requires_plugin OpenaiLinkAnalyzer::PLUGIN_NAME
    
    before_action :ensure_logged_in
    before_action :ensure_staff, only: [:statistics, :clear_statistics, :test_api]
    skip_before_action :check_xhr, only: [:callback]
    
    def analyze
      url = params[:url]
      category_id = params[:category_id]
      
      if url.blank?
        render json: { success: false, error: "URL is required" }, status: 400
        return
      end
      
      if category_id.blank?
        render json: { success: false, error: "Category is required" }, status: 400
        return
      end
      
      # Process URL and create topic
      result = OpenaiLinkAnalyzer::UrlProcessor.new.process_and_create_topic(url, category_id, current_user)
      
      if result
        render json: { 
          success: true, 
          topic_id: result.id, 
          topic_url: result.url
        }
      else
        render json: { success: false, error: "Failed to process URL" }, status: 422
      end
    end
    
    def statistics
      # Simplified statistics for now
      render json: {
        success: true,
        stats: {
          total_analyzed: 0,
          success_rate: 0,
          last_analyzed: nil,
          popular_categories: []
        }
      }
    end
    
    def clear_statistics
      # No statistics to clear for now
      render json: { success: true }
    end
    
    def test_api
      api_key = SiteSetting.openai_api_key
      
      if api_key.blank?
        render json: { success: false, error: "API key is not configured" }
        return
      end
      
      api_client = OpenaiLinkAnalyzer::ApiClient.new
      
      # Test with a simple query
      test_result = api_client.analyze_url("https://example.com", "Test page content for API test")
      
      if test_result[:error]
        render json: { success: false, error: test_result[:error] }
      else
        render json: { success: true, message: "API connection successful" }
      end
    end
    
    def categories
      # Get list of categories for dropdown
      categories = Category.secured(guardian).where(read_restricted: false)
      
      render json: {
        categories: categories.map { |c| { id: c.id, name: c.name } }
      }
    end
  end
end 