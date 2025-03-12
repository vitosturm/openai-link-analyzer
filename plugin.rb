# frozen_string_literal: true

# name: openai-link-analyzer
# about: TODO
# meta_topic_id: TODO
# version: 0.0.1
# authors: Discourse
# url: TODO
# required_version: 2.7.0

enabled_site_setting :openai_link_analyzer_enabled

module ::OpenaiLinkAnalyzer
  PLUGIN_NAME = "openai-link-analyzer"
end

require_relative "lib/openai_link_analyzer/engine"

after_initialize do
  # Code which should run after Rails has finished booting
end
