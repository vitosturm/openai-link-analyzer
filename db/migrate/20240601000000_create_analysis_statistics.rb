# frozen_string_literal: true

class CreateAnalysisStatistics < ActiveRecord::Migration[6.1]
  def change
    create_table :openai_link_analyzer_analysis_statistics do |t|
      t.string :url, null: false
      t.integer :category_id, null: false
      t.integer :user_id, null: false
      t.boolean :success, default: false
      t.string :error_message
      t.timestamps
    end
    
    add_index :openai_link_analyzer_analysis_statistics, :user_id
    add_index :openai_link_analyzer_analysis_statistics, :category_id
    add_index :openai_link_analyzer_analysis_statistics, :created_at
  end
end 