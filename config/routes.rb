# frozen_string_literal: true

OpenaiLinkAnalyzer::Engine.routes.draw do
  post '/analyze' => 'analyzer#analyze'
  get '/statistics' => 'analyzer#statistics'
  delete '/statistics/clear' => 'analyzer#clear_statistics'
  get '/test_api' => 'analyzer#test_api'
  get '/categories' => 'analyzer#categories'
  # define routes here
end
