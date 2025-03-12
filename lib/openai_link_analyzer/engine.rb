# frozen_string_literal: true

module OpenaiLinkAnalyzer
  class Engine < ::Rails::Engine
    engine_name "openai_link_analyzer"
    isolate_namespace OpenaiLinkAnalyzer
    config.autoload_paths << File.join(config.root, "lib")
    scheduled_job_dir = "#{config.root}/app/jobs/scheduled"
    config.to_prepare do
      Rails.autoloaders.main.eager_load_dir(scheduled_job_dir) if Dir.exist?(scheduled_job_dir)
    end

    config.after_initialize do
      Discourse::Application.routes.append do
        mount ::OpenaiLinkAnalyzer::Engine, at: "openai-link-analyzer"
      end
    end
  end
end
