# frozen_string_literal: true

require "net/http"
require "uri"
require "nokogiri"

module OpenaiLinkAnalyzer
  class UrlProcessor
    def fetch_content(url)
      begin
        uri = URI.parse(url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = uri.scheme == "https"
        
        request = Net::HTTP::Get.new(uri.request_uri)
        request["User-Agent"] = "Discourse OpenAI Link Analyzer Plugin"
        
        response = http.request(request)
        
        if response.code.to_i == 200
          response.body
        else
          Rails.logger.error("Error fetching content from URL: HTTP #{response.code}")
          nil
        end
      rescue StandardError => e
        Rails.logger.error("Error fetching content from URL: #{e.message}")
        nil
      end
    end
    
    def extract_text_content(html)
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
          description: meta_description,
          content: content
        }
      rescue StandardError => e
        Rails.logger.error("Error parsing HTML: #{e.message}")
        nil
      end
    end
    
    def process_and_create_topic(url, category_id, user)
      # Fetch content from URL
      html_content = fetch_content(url)
      
      return nil unless html_content
      
      # Extract text content
      content_result = extract_text_content(html_content)
      
      return nil unless content_result
      
      # Analyze content with OpenAI
      api_client = ApiClient.new
      analysis = api_client.analyze_url(url, "#{content_result[:title]}\n#{content_result[:description]}\n#{content_result[:content]}")
      
      return nil if analysis[:error].present?
      
      category = Category.find_by(id: category_id)
      
      return nil unless category
      
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
        post.topic
      else
        nil
      end
    end
  end
end 