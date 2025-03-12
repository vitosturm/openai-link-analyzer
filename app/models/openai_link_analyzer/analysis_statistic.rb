# frozen_string_literal: true

module OpenaiLinkAnalyzer
  class AnalysisStatistic < ActiveRecord::Base
    belongs_to :user
    belongs_to :category
    
    validates :url, presence: true
    validates :category_id, presence: true
    validates :user_id, presence: true
    
    def self.total_analyzed
      count
    end
    
    def self.success_rate
      return 0 if count == 0
      ((where(success: true).count.to_f / count) * 100).round
    end
    
    def self.popular_categories(limit = 5)
      select("category_id, COUNT(*) as count")
        .group(:category_id)
        .order("count DESC")
        .limit(limit)
        .map do |stat|
          category = Category.find_by(id: stat.category_id)
          {
            id: stat.category_id,
            name: category&.name || "Unknown",
            count: stat.count
          }
        end
    end
  end
end 