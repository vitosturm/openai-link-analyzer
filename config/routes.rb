# frozen_string_literal: true

OpenaiLinkAnalyzer::Engine.routes.draw do
  get "/examples" => "examples#index"
  # define routes here
end

Discourse::Application.routes.draw { mount ::OpenaiLinkAnalyzer::Engine, at: "openai-link-analyzer" }
