# frozen_string_literal: true

require 'rails_helper'

describe OpenaiLinkAnalyzer::AnalyzerController do
  fab!(:user) { Fabricate(:user) }
  fab!(:admin) { Fabricate(:admin) }
  fab!(:category) { Fabricate(:category) }
  
  before do
    SiteSetting.openai_link_analyzer_enabled = true
    SiteSetting.openai_api_key = "test_api_key"
  end
  
  describe "#analyze" do
    let(:url) { "https://example.com" }
    let(:params) { { url: url, category_id: category.id } }
    
    context "when user is not logged in" do
      it "returns a 403 status" do
        post "/openai-link-analyzer/analyze.json", params: params
        expect(response.status).to eq(403)
      end
    end
    
    context "when user is logged in" do
      before do
        sign_in(user)
      end
      
      it "returns a 400 status when URL is missing" do
        post "/openai-link-analyzer/analyze.json", params: { category_id: category.id }
        expect(response.status).to eq(400)
        expect(response.parsed_body["error"]).to include("URL is required")
      end
      
      it "returns a 400 status when category_id is missing" do
        post "/openai-link-analyzer/analyze.json", params: { url: url }
        expect(response.status).to eq(400)
        expect(response.parsed_body["error"]).to include("Category is required")
      end
      
      it "processes the URL and creates a topic" do
        # Mock the URL processor
        url_processor = instance_double(OpenaiLinkAnalyzer::UrlProcessor)
        expect(OpenaiLinkAnalyzer::UrlProcessor).to receive(:new).and_return(url_processor)
        
        topic = Fabricate(:topic, user: user, category: category)
        expect(url_processor).to receive(:process_and_create_topic).with(url, category.id.to_s, user).and_return(topic)
        
        post "/openai-link-analyzer/analyze.json", params: params
        expect(response.status).to eq(200)
        expect(response.parsed_body["topic_id"]).to eq(topic.id)
      end
    end
  end
  
  describe "#statistics" do
    context "when user is not an admin" do
      before do
        sign_in(user)
      end
      
      it "returns a 403 status" do
        get "/openai-link-analyzer/statistics.json"
        expect(response.status).to eq(403)
      end
    end
    
    context "when user is an admin" do
      before do
        sign_in(admin)
      end
      
      it "returns statistics data" do
        # Create some analysis statistics
        3.times do
          OpenaiLinkAnalyzer::AnalysisStatistic.create!(
            url: "https://example.com",
            category_id: category.id,
            user_id: user.id,
            success: true
          )
        end
        
        get "/openai-link-analyzer/statistics.json"
        expect(response.status).to eq(200)
        
        body = response.parsed_body
        expect(body["total_analyzed"]).to eq(3)
        expect(body["success_rate"]).to eq(100)
        expect(body["popular_categories"].length).to eq(1)
      end
    end
  end
  
  describe "#test_api" do
    context "when user is not an admin" do
      before do
        sign_in(user)
      end
      
      it "returns a 403 status" do
        get "/openai-link-analyzer/test_api.json"
        expect(response.status).to eq(403)
      end
    end
    
    context "when user is an admin" do
      before do
        sign_in(admin)
      end
      
      it "returns success when API key is valid" do
        stub_request(:post, /api.openai.com/).to_return(
          status: 200,
          body: { choices: [{ message: { content: "Test successful" } }] }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
        
        get "/openai-link-analyzer/test_api.json"
        expect(response.status).to eq(200)
        expect(response.parsed_body["success"]).to eq(true)
      end
      
      it "returns error when API key is invalid" do
        stub_request(:post, /api.openai.com/).to_return(
          status: 401,
          body: { error: { message: "Invalid API key" } }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
        
        get "/openai-link-analyzer/test_api.json"
        expect(response.status).to eq(200)
        expect(response.parsed_body["success"]).to eq(false)
        expect(response.parsed_body["error"]).to include("Invalid API key")
      end
    end
  end
end 