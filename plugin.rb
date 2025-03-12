# frozen_string_literal: true

# name: openai-link-analyzer
# about: Analyzes URLs using OpenAI and creates summaries with automated topic creation
# version: 0.3
# authors: vitosturm
# url: https://github.com/vitosturm/openai-link-analyzer
# required_version: 2.7.0

enabled_site_setting :openai_link_analyzer_enabled
register_asset "stylesheets/common/openai-link-analyzer.scss"

module ::OpenaiLinkAnalyzer
  PLUGIN_NAME = "openai_link_analyzer"
  
  class Engine < ::Rails::Engine
    engine_name PLUGIN_NAME
    isolate_namespace OpenaiLinkAnalyzer
  end

  class AnalysisStatistic < ActiveRecord::Base
    self.table_name = "openai_link_analyzer_statistics"
  end
end

after_initialize do
  require_relative "lib/openai_link_analyzer/engine"
  require_relative "lib/openai_link_analyzer/api_client"
  require_relative "lib/openai_link_analyzer/url_processor"
  
  # Register plugin API routes
  Discourse::Application.routes.append do
    mount ::OpenaiLinkAnalyzer::Engine, at: "/openai-link-analyzer"
    
    get "/admin/plugins/openai-link-analyzer" => "admin/plugins#index", constraints: StaffConstraint.new
  end
  
  # Register site settings
  Site.preloaded_category_custom_fields << "openai_link_analyzer_enabled"
  
  # Add controllers and initialize plugin
  load File.expand_path('../app/controllers/openai_link_analyzer/analyzer_controller.rb', __FILE__)
  
  # Add header icons
  register_svg_icon "magic" # For the magic wand icon
  register_svg_icon "newspaper" # For news/article icon

  # Add header button
  Discourse::Application.routes.append do
    get "u/:username/openai-link-analyzer" => "users#show", constraints: { username: USERNAME_ROUTE_FORMAT }
  end

  add_to_serializer(:current_user, :can_use_link_analyzer) do
    return false if !scope.user
    return true if SiteSetting.openai_link_analyzer_enabled
    false
  end

  # Add header button
  register_html_builder("header-before-notifications") do |controller|
    if controller.current_user && SiteSetting.openai_link_analyzer_enabled
      controller.helpers.react_component("header-analyzer-button")
    end
  end

  ::OpenaiLinkAnalyzer::Engine.routes.draw do
    post '/analyze' => 'analyzer#analyze'
    get '/statistics' => 'analyzer#statistics'
    delete '/statistics/clear' => 'analyzer#clear_statistics'
    get '/test_api' => 'analyzer#test_api'
    get '/categories' => 'analyzer#categories'
  end

  # Ensure we have a table for analysis statistics
  on_next_migration do
    unless ActiveRecord::Base.connection.table_exists?(:openai_link_analyzer_statistics)
      ActiveRecord::Base.connection.create_table(:openai_link_analyzer_statistics) do |t|
        t.datetime :analyzed_at, null: false
        t.integer :category_id, null: false
        t.boolean :success, null: false, default: false
        t.timestamps null: false
      end
      
      ActiveRecord::Base.connection.add_index :openai_link_analyzer_statistics, :analyzed_at
      ActiveRecord::Base.connection.add_index :openai_link_analyzer_statistics, :category_id
    end
  end
end 