# frozen_string_literal: true

require "net/http"
require "uri"
require "nokogiri"

module OpenaiLinkAnalyzer
  class UrlProcessor
    def self.fetch_content(url)
      begin
        uri = URI.parse(url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = uri.scheme == "https"
        
        request = Net::HTTP::Get.new(uri.request_uri)
        request["User-Agent"] = "Discourse OpenAI Link Analyzer Plugin"
        
        response = http.request(request)
        
        if response.code.to_i == 200
          extract_text_content(response.body)
        else
          { error: "Failed to fetch URL: #{response.code}" }
        end
      rescue StandardError => e
        Rails.logger.error("Error fetching URL content: #{e.message}")
        { error: "Error fetching URL: #{e.message}" }
      end
    end
    
    def self.extract_text_content(html)
      begin
        doc = Nokogiri::HTML(html)
        
        # Remove script, style elements and comments
        doc.search('script, style, comment').remove
        
        # Extract the text content
        content = doc.xpath('//body').text.gsub(/\s+/, ' ').strip
        
        # Get page title
        title = doc.at_css('title')&.text || ""
        
        # Get meta description
        meta_description = doc.at_css('meta[name="description"]')&.[]('content') || ""
        
        {
          title: title,
          meta_description: meta_description,
          content: content
        }
      rescue StandardError => e
        Rails.logger.error("Error parsing HTML: #{e.message}")
        { error: "Error parsing HTML: #{e.message}" }
      end
    end
    
    def self.process_and_create_topic(url, category_id, user_id)
      # Fetch content from URL
      content_result = fetch_content(url)
      
      if content_result[:error].present?
        return { success: false, error: content_result[:error] }
      end
      
      # Analyze content with OpenAI
      api_client = ApiClient.new
      analysis = api_client.analyze_url(url, "#{content_result[:title]}\n#{content_result[:meta_description]}\n#{content_result[:content]}")
      
      if analysis[:error].present?
        return { success: false, error: analysis[:error] }
      end
      
      # Create topic with the analyzed content
      user = User.find_by(id: user_id)
      
      if !user
        return { success: false, error: "User not found" }
      end
      
      category = Category.find_by(id: category_id)
      
      if !category
        return { success: false, error: "Category not found" }
      end
      
      # Create topic with analysis results
      topic_creator = PostCreator.new(
        user,
        title: analysis[:title],
        raw: "#{analysis[:summary]}\n\nOriginal URL: #{url}",
        category: category_id,
        skip_validations: true
      )
      
      post = topic_creator.create
      
      if post.present? && post.topic.present?
        { 
          success: true, 
          topic_id: post.topic.id,
          topic_url: post.topic.url,
          title: analysis[:title],
          summary: analysis[:summary]
        }
      else
        { success: false, error: "Failed to create topic" }
      end
    end
  end
end 