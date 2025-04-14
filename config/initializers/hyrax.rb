# frozen_string_literal: true

# Use this to override any Hyrax configuration from the Knapsack
Hyrax.config do |config|
  config.simple_schema_loader_config_search_paths.unshift(HykuKnapsack::Engine.root)
  config.simple_schema_loader_config_search_paths << IiifPrint::Engine.root
end

Rails.application.config.after_initialize do
  Hyrax.config do |config|
    config.register_curation_concern :newspaper
  end
end