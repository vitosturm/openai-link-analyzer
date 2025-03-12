# frozen_string_literal: true

# name: openai-link-analyzer
# about: Analyzes URLs using OpenAI and creates summaries with automated topic creation
# version: 0.3.0
# authors: vitosturm
# url: https://github.com/vitosturm/openai-link-analyzer
# required_version: 2.7.0

enabled_site_setting :openai_link_analyzer_enabled
register_asset "stylesheets/openai-link-analyzer.scss"

# Add icons used by the plugin
register_svg_icon "magic"      # For the magic wand icon in header
register_svg_icon "newspaper"  # For the news/article icon

module ::OpenaiLinkAnalyzer
  PLUGIN_NAME = "openai_link_analyzer"
end

require_relative "lib/openai_link_analyzer/engine"

after_initialize do
  # Add controllers and helpers
  load File.expand_path('../app/controllers/openai_link_analyzer/analyzer_controller.rb', __FILE__)
  load File.expand_path('../app/models/openai_link_analyzer/analysis_statistic.rb', __FILE__)
  
  # Add API client and URL processor
  require_relative "lib/openai_link_analyzer/openai_api_client"
  require_relative "lib/openai_link_analyzer/url_processor"
  
  # Add user route for analyzer
  Discourse::Application.routes.append do
    get "u/:username/openai-link-analyzer" => "users#show", constraints: { username: USERNAME_ROUTE_FORMAT }
  end
  
  # Add serializer method for checking if user can use analyzer
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
end
