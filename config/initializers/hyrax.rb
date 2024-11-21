# frozen_string_literal: true

# Use this to override any Hyrax configuration from the Knapsack

Rails.application.config.before_initialize do
  Hyrax.config do |config|
  # Injected via `rails g hyrax:work_resource Newspaper`
    config.register_curation_concern :newspaper

    config.simple_schema_loader_config_search_paths.unshift(HykuKnapsack::Engine.root)
    config.simple_schema_loader_config_search_paths << IiifPrint::Engine.root
  end
end

Rails.application.config.after_initialize do
  # Ensure that valid_child_concerns are set with all the curation concerns including
  # the ones registered from the Knapsack
  Hyrax.config.curation_concerns.each do |concern|
    concern.valid_child_concerns = Hyrax.config.curation_concerns
    "#{concern}Resource".safe_constantize&.valid_child_concerns = Hyrax.config.curation_concerns
  end
end
