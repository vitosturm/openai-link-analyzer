# frozen_string_literal: true

module OpenaiLinkAnalyzer
  class AnalyzerController < ::ApplicationController
    requires_plugin OpenaiLinkAnalyzer::PLUGIN_NAME
    
    before_action :ensure_logged_in
    before_action :ensure_openai_link_analyzer_enabled
    
    def analyze
      # Validate parameters
      url = params.require(:url)
      category_id = params.require(:category_id)
      
      # Check if the category exists
      category = Category.find_by(id: category_id)
      
      if category.nil?
        return render json: { error: I18n.t("openai_link_analyzer.errors.invalid_category") }, status: 400
      end
      
      # Process the URL
      begin
        # Fetch content from the URL
        url_processor = UrlProcessor.new(url)
        content_data = url_processor.fetch_content
        
        # Analyze the content with OpenAI
        openai_client = OpenaiApiClient.new
        analysis = openai_client.analyze_content(content_data[:content])
        
        # Create topic
        topic = create_topic(url, analysis, category)
        
        # Record statistic
        AnalysisStatistic.record_analysis(current_user.id, url, category_id, true)
        
        render json: {
          success: true,
          title: analysis["title"],
          summary: analysis["summary"],
          topic_id: topic.id,
          topic_url: topic.url
        }
      rescue UrlProcessor::Error => e
        AnalysisStatistic.record_analysis(current_user.id, url, category_id, false, e.message)
        render json: { error: e.message }, status: 400
      rescue OpenaiApiClient::Error => e
        AnalysisStatistic.record_analysis(current_user.id, url, category_id, false, e.message)
        render json: { error: e.message }, status: 400
      rescue StandardError => e
        AnalysisStatistic.record_analysis(current_user.id, url, category_id, false, e.message)
        render json: { error: e.message }, status: 500
      end
    end
    
    def statistics
      guardian.ensure_can_use_admin_plugins!
      
      stats = AnalysisStatistic.statistics
      
      # Add category names to the popular categories
      popular_categories_with_names = {}
      stats[:popular_categories].each do |category_id, count|
        category = Category.find_by(id: category_id)
        name = category ? category.name : I18n.t("openai_link_analyzer.unknown_category")
        popular_categories_with_names[name] = count
      end
      
      stats[:popular_categories] = popular_categories_with_names
      
      render json: stats
    end
    
    def clear_statistics
      guardian.ensure_can_use_admin_plugins!
      
      AnalysisStatistic.clear_all
      
      render json: { success: true }
    end
    
    def test_api
      guardian.ensure_can_use_admin_plugins!
      
      begin
        openai_client = OpenaiApiClient.new
        result = openai_client.test_connection
        
        render json: result
      rescue => e
        render json: { success: false, error: e.message }
      end
    end
    
    def categories
      render json: { categories: Category.secured(guardian).pluck(:id, :name) }
    end
    
    private
    
    def ensure_openai_link_analyzer_enabled
      unless SiteSetting.openai_link_analyzer_enabled
        render json: { error: I18n.t("openai_link_analyzer.errors.plugin_disabled") }, status: 403
      end
    end
    
    def create_topic(url, analysis, category)
      creator = PostCreator.new(
        current_user,
        skip_validations: true,
        title: analysis["title"],
        raw: "#{analysis["summary"]}\n\n#{I18n.t("openai_link_analyzer.original_url")}: #{url}",
        category: category.id
      )
      
      post = creator.create
      
      if post.present? && post.topic.present?
        post.topic
      else
        raise StandardError.new(I18n.t("openai_link_analyzer.errors.topic_creation_failed"))
      end
    end
  end
end 