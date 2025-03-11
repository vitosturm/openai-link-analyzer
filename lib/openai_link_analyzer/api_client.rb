# frozen_string_literal: true

require "net/http"
require "uri"
require "json"

module OpenaiLinkAnalyzer
  class ApiClient
    def initialize
      @api_key = SiteSetting.openai_api_key
      @model = SiteSetting.openai_model || "gpt-4"
    end

    def analyze_url(url, content)
      raise "OpenAI API Key not configured" if @api_key.blank?
      
      uri = URI.parse("https://api.openai.com/v1/chat/completions")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      
      request = Net::HTTP::Post.new(uri.request_uri)
      request["Content-Type"] = "application/json"
      request["Authorization"] = "Bearer #{@api_key}"
      
      messages = [
        { role: "system", content: "You are a helpful assistant that analyzes web content and provides concise summaries." },
        { role: "user", content: "Please analyze this web page content and provide: 1) A concise summary of what it's about (max 3 sentences), 2) A suggested title for a discussion topic about this content (max 10 words). Format your response as JSON with 'summary' and 'title' fields.\n\nURL: #{url}\n\nContent: #{content[0..3000]}..." }
      ]
      
      request.body = {
        model: @model,
        messages: messages,
        temperature: 0.7,
        max_tokens: 500,
        response_format: { type: "json_object" }
      }.to_json
      
      response = http.request(request)
      
      if response.code.to_i == 200
        result = JSON.parse(response.body)
        content = result["choices"][0]["message"]["content"]
        begin
          parsed = JSON.parse(content)
          return { 
            summary: parsed["summary"], 
            title: parsed["title"] 
          }
        rescue JSON::ParserError => e
          Rails.logger.error("Failed to parse OpenAI response: #{e.message}")
          return { error: "Failed to parse response" }
        end
      else
        Rails.logger.error("OpenAI API error: #{response.body}")
        return { error: "API request failed: #{response.code}" }
      end
    end
  end
end 