# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'

module OpenaiLinkAnalyzer
  class OpenaiApiClient
    class Error < StandardError; end
    
    def initialize(api_key = SiteSetting.openai_api_key, model = SiteSetting.openai_model)
      @api_key = api_key
      @model = model
      
      raise I18n.t("openai_link_analyzer.errors.missing_api_key") if @api_key.blank?
    end
    
    def analyze_content(content)
      response = make_completion_request(content)
      parse_response(response)
    end
    
    def test_connection
      uri = URI.parse("https://api.openai.com/v1/models")
      request = Net::HTTP::Get.new(uri)
      request["Authorization"] = "Bearer #{@api_key}"
      
      response = make_request(uri, request)
      
      if response.is_a?(Net::HTTPSuccess)
        { success: true }
      else
        { success: false, error: response.message }
      end
    rescue => e
      { success: false, error: e.message }
    end
    
    private
    
    def make_completion_request(content)
      uri = URI.parse("https://api.openai.com/v1/chat/completions")
      request = Net::HTTP::Post.new(uri)
      request["Content-Type"] = "application/json"
      request["Authorization"] = "Bearer #{@api_key}"
      
      messages = [
        { role: "system", content: "You are a helpful assistant that analyzes web content and creates concise summaries." },
        { role: "user", content: "Please analyze this content and provide a JSON response with the following format: {\"title\": \"Suggested title\", \"summary\": \"Concise summary in 2-3 sentences\"}. Here's the content: #{content}" }
      ]
      
      request.body = {
        model: @model,
        messages: messages,
        temperature: 0.7,
        max_tokens: 500
      }.to_json
      
      make_request(uri, request)
    end
    
    def make_request(uri, request)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_PEER
      
      response = http.request(request)
      
      if response.is_a?(Net::HTTPSuccess)
        response
      else
        Rails.logger.error("OpenAI API error: #{response.code} - #{response.message}")
        Rails.logger.error("Response body: #{response.body}")
        raise Error, "OpenAI API error: #{response.message} (#{response.code})"
      end
    rescue => e
      Rails.logger.error("OpenAI API request failed: #{e.message}")
      raise Error, "Failed to communicate with OpenAI API: #{e.message}"
    end
    
    def parse_response(response)
      body = JSON.parse(response.body)
      content = body["choices"][0]["message"]["content"]
      
      # Parse the JSON from the content
      begin
        analysis = JSON.parse(content)
        
        # Ensure the analysis has the expected format
        unless analysis.key?("title") && analysis.key?("summary")
          raise Error, "Invalid response format from OpenAI API"
        end
        
        analysis
      rescue JSON::ParserError => e
        Rails.logger.error("Failed to parse OpenAI API response: #{e.message}")
        Rails.logger.error("Response content: #{content}")
        raise Error, "Failed to parse response from OpenAI API"
      end
    end
  end
end 