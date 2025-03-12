# frozen_string_literal: true

require 'rails_helper'

describe OpenaiLinkAnalyzer::AnalysisStatistic do
  fab!(:user) { Fabricate(:user) }
  fab!(:category) { Fabricate(:category) }
  
  describe "validations" do
    it "requires a URL" do
      stat = OpenaiLinkAnalyzer::AnalysisStatistic.new(
        category_id: category.id,
        user_id: user.id
      )
      expect(stat.valid?).to eq(false)
      expect(stat.errors[:url]).to be_present
    end
    
    it "requires a category_id" do
      stat = OpenaiLinkAnalyzer::AnalysisStatistic.new(
        url: "https://example.com",
        user_id: user.id
      )
      expect(stat.valid?).to eq(false)
      expect(stat.errors[:category_id]).to be_present
    end
    
    it "requires a user_id" do
      stat = OpenaiLinkAnalyzer::AnalysisStatistic.new(
        url: "https://example.com",
        category_id: category.id
      )
      expect(stat.valid?).to eq(false)
      expect(stat.errors[:user_id]).to be_present
    end
    
    it "is valid with all required attributes" do
      stat = OpenaiLinkAnalyzer::AnalysisStatistic.new(
        url: "https://example.com",
        category_id: category.id,
        user_id: user.id
      )
      expect(stat.valid?).to eq(true)
    end
  end
  
  describe "class methods" do
    before do
      5.times do |i|
        OpenaiLinkAnalyzer::AnalysisStatistic.create!(
          url: "https://example.com/#{i}",
          category_id: category.id,
          user_id: user.id,
          success: i < 4 # 4 successful, 1 failed
        )
      end
    end
    
    describe ".total_analyzed" do
      it "returns the total count of analysis statistics" do
        expect(OpenaiLinkAnalyzer::AnalysisStatistic.total_analyzed).to eq(5)
      end
    end
    
    describe ".success_rate" do
      it "returns the percentage of successful analyses" do
        expect(OpenaiLinkAnalyzer::AnalysisStatistic.success_rate).to eq(80) # 4/5 = 80%
      end
      
      it "returns 0 when there are no analyses" do
        OpenaiLinkAnalyzer::AnalysisStatistic.delete_all
        expect(OpenaiLinkAnalyzer::AnalysisStatistic.success_rate).to eq(0)
      end
    end
    
    describe ".popular_categories" do
      it "returns the most popular categories" do
        another_category = Fabricate(:category)
        3.times do
          OpenaiLinkAnalyzer::AnalysisStatistic.create!(
            url: "https://example.com/other",
            category_id: another_category.id,
            user_id: user.id,
            success: true
          )
        end
        
        popular = OpenaiLinkAnalyzer::AnalysisStatistic.popular_categories
        expect(popular.length).to eq(2)
        expect(popular.first[:id]).to eq(another_category.id)
        expect(popular.first[:count]).to eq(3)
        expect(popular.second[:id]).to eq(category.id)
        expect(popular.second[:count]).to eq(5)
      end
    end
  end
end 