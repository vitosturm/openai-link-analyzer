# frozen_string_literal: true

OpenaiLinkAnalyzer::Engine.routes.draw do
  get "/" => "analyzer#index"
  get "/categories" => "analyzer#categories"
  post "/analyze" => "analyzer#analyze"
end 