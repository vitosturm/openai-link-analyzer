# frozen_string_literal: true

require 'rails_helper'

describe OpenaiLinkAnalyzer::UrlProcessor do
  let(:url) { "https://example.com" }
  let(:url_processor) { OpenaiLinkAnalyzer::UrlProcessor.new }
  let(:response_body) { "<html><head><title>Example Site</title><meta name='description' content='Example description'></head><body><p>Example content</p></body></html>" }
  
  before do
    SiteSetting.openai_link_analyzer_enabled = true
    SiteSetting.openai_api_key = "test_api_key"
  end
  
  describe "#fetch_content" do
    it "fetches content from a URL" do
      stub_request(:get, url).to_return(
        status: 200,
        body: response_body,
        headers: { 'Content-Type' => 'text/html' }
      )
      
      content = url_processor.fetch_content(url)
      expect(content).to eq(response_body)
    end
    
    it "returns nil and logs error when request fails" do
      stub_request(:get, url).to_return(status: 404)
      
      expect(Rails.logger).to receive(:error).with(/Error fetching content from URL/)
      expect(url_processor.fetch_content(url)).to be_nil
    end
  end
  
  describe "#extract_text_content" do
    it "extracts title, description, and content from HTML" do
      result = url_processor.extract_text_content(response_body)
      
      expect(result[:title]).to eq("Example Site")
      expect(result[:description]).to eq("Example description")
      expect(result[:content]).to include("Example content")
    end
    
    it "handles missing elements gracefully" do
      minimal_html = "<html><body>Just some text</body></html>"
      result = url_processor.extract_text_content(minimal_html)
      
      expect(result[:title]).to be_nil
      expect(result[:description]).to be_nil
      expect(result[:content]).to include("Just some text")
    end
  end
  
  describe "#process_and_create_topic" do
    let(:category) { Fabricate(:category) }
    let(:user) { Fabricate(:user) }
    let(:openai_response) { 
      {
        "choices" => [{
          "message" => {
            "content" => "{\n\"title\": \"Analyzed Title\",\n\"summary\": \"Analyzed summary of the content.\"\n}"
          }
        }]
      }
    }
    
    before do
      stub_request(:get, url).to_return(
        status: 200,
        body: response_body,
        headers: { 'Content-Type' => 'text/html' }
      )
      
      stub_request(:post, /api.openai.com/).to_return(
        status: 200,
        body: openai_response.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
    end
    
    it "processes a URL and creates a topic" do
      expect {
        url_processor.process_and_create_topic(url, category.id, user)
      }.to change { Topic.count }.by(1)
      
      topic = Topic.last
      expect(topic.title).to eq("Analyzed Title")
      expect(topic.first_post.raw).to include("Analyzed summary of the content")
      expect(topic.first_post.raw).to include(url)
    end
  end
end 