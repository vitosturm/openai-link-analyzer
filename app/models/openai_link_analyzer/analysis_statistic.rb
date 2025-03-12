# frozen_string_literal: true

module OpenaiLinkAnalyzer
  class AnalysisStatistic < ::ActiveRecord::Base
    self.table_name = "openai_link_analyzer_analysis_statistics"

    belongs_to :user
    belongs_to :category

    validates :url, presence: true
    validates :category_id, presence: true
    validates :user_id, presence: true

    def self.record_analysis(user_id, url, category_id, success, error_message = nil)
      create!(
        user_id: user_id,
        url: url,
        category_id: category_id,
        success: success,
        error_message: error_message
      )
    end

    def self.statistics
      {
        total_analyzed: count,
        success_count: where(success: true).count,
        failure_count: where(success: false).count,
        popular_categories: group(:category_id)
                              .order('count_all DESC')
                              .limit(5)
                              .count
      }
    end

    def self.clear_all
      delete_all
    end
  end
end 