# frozen_string_literal: true

module OpenaiLinkAnalyzer
  class AnalyzerController < ::ApplicationController
    requires_plugin OpenaiLinkAnalyzer::PLUGIN_NAME
    
    before_action :ensure_logged_in
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
    
    def categories
      # Get list of categories for dropdown
      categories = Category.secured(guardian).where(read_restricted: false)
      
      render json: {
        categories: categories.map { |c| { id: c.id, name: c.name } }
      }
    end
  end
end 