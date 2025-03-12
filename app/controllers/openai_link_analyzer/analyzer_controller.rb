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
        render json: { success: false, error: "URL cannot be blank" }, status: 400
        return
      end
      
      if category_id.blank?
        render json: { success: false, error: "Category must be selected" }, status: 400
        return
      end
      
      # Process URL and create topic
      result = OpenaiLinkAnalyzer::UrlProcessor.process_and_create_topic(url, category_id, current_user.id)
      
      # Record statistics
      OpenaiLinkAnalyzer::AnalysisStatistic.create!(
        analyzed_at: Time.now,
        category_id: category_id.to_i,
        success: result[:success]
      )
      
      # Publish statistics update to message bus
      MessageBus.publish('/openai-link-analyzer/statistics', { updated: true })
      
      if result[:success]
        render json: { 
          success: true, 
          topic_id: result[:topic_id], 
          topic_url: result[:topic_url],
          title: result[:title],
          summary: result[:summary]
        }
      else
        render json: { success: false, error: result[:error] }, status: 422
      end
    end
    
    def statistics
      # Generate statistics for admin interface
      total_analyzed = OpenaiLinkAnalyzer::AnalysisStatistic.count
      successful = OpenaiLinkAnalyzer::AnalysisStatistic.where(success: true).count
      success_rate = total_analyzed > 0 ? (successful.to_f / total_analyzed * 100).round(2) : 0
      
      # Get the last analyzed timestamp
      last_analyzed = OpenaiLinkAnalyzer::AnalysisStatistic.order(analyzed_at: :desc).first&.analyzed_at
      
      # Get popular categories
      popular_categories = ActiveRecord::Base.connection.execute(
        "SELECT c.id, c.name, COUNT(*) as count 
         FROM openai_link_analyzer_statistics s
         JOIN categories c ON s.category_id = c.id
         GROUP BY c.id, c.name
         ORDER BY count DESC
         LIMIT 10"
      ).to_a
      
      render json: {
        success: true,
        stats: {
          total_analyzed: total_analyzed,
          success_rate: success_rate,
          last_analyzed: last_analyzed,
          popular_categories: popular_categories
        }
      }
    end
    
    def clear_statistics
      OpenaiLinkAnalyzer::AnalysisStatistic.delete_all
      MessageBus.publish('/openai-link-analyzer/statistics', { updated: true })
      
      render json: { success: true }
    end
    
    def test_api
      api_key = SiteSetting.openai_api_key
      
      if api_key.blank?
        render json: { success: false, message: "API key is not configured" }
        return
      end
      
      api_client = OpenaiLinkAnalyzer::ApiClient.new
      
      # Test with a simple query
      test_result = api_client.analyze_url("https://example.com", "Test page content for API test")
      
      if test_result[:error]
        render json: { success: false, message: test_result[:error] }
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