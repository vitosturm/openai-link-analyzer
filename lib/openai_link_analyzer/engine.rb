# frozen_string_literal: true

module ::OpenaiLinkAnalyzer
  class Engine < ::Rails::Engine
    engine_name OpenaiLinkAnalyzer::PLUGIN_NAME
    isolate_namespace OpenaiLinkAnalyzer
    
    config.after_initialize do
      # Initialize routes or other configuration after Rails initialization
    end
  end
end 