# frozen_string_literal: true

# name: openai-link-analyzer
# about: Analyzes URLs using OpenAI and creates summaries with automated topic creation
# version: 0.1
# authors: Your Name
# url: https://github.com/vitosturm/openai-link-analyzer

enabled_site_setting :openai_link_analyzer_enabled
register_asset "stylesheets/common/openai-link-analyzer.scss"

module ::OpenaiLinkAnalyzer
  PLUGIN_NAME = "openai_link_analyzer"
  
  class Engine < ::Rails::Engine
    engine_name PLUGIN_NAME
    isolate_namespace OpenaiLinkAnalyzer
  end
end

after_initialize do
  require_relative "lib/openai_link_analyzer/engine"
  require_relative "lib/openai_link_analyzer/api_client"
  require_relative "lib/openai_link_analyzer/url_processor"
  
  # Register plugin API routes
  Discourse::Application.routes.append do
    mount ::OpenaiLinkAnalyzer::Engine, at: "/openai-link-analyzer"
  end
  
  # Register site settings
  Site.preloaded_category_custom_fields << "openai_link_analyzer_enabled"
  
  # Add controllers and initialize plugin
  load File.expand_path('../app/controllers/openai_link_analyzer/analyzer_controller.rb', __FILE__)
end 