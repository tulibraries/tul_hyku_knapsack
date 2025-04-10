# frozen_string_literal: true

if ENV["K8"] == "no"
  Rails.application.config.to_prepare do
    Hyrax.config do |config|
      # Injected via `rails g hyrax:work_resource NewspaperResource`
      config.register_curation_concern :newspaper_resource
    end

    Hyrax.config.curation_concerns.each do |concern|
      klass_name = "#{concern}"
      klass = klass_name.safe_constantize

      if klass
        klass.valid_child_concerns = Hyrax.config.curation_concerns
      else
        Rails.logger.error("Could not constantize #{klass_name}")
      end
    end
  end
end

# Use this to override any Hyrax configuration from the Knapsack
Hyrax.config do |config|
  if ENV["K8"] == "yes"
    # Injected via `rails g hyrax:work_resource NewspaperResource`
    config.register_curation_concern :newspaper_resource
  end

  config.simple_schema_loader_config_search_paths.unshift(HykuKnapsack::Engine.root)
  config.simple_schema_loader_config_search_paths << IiifPrint::Engine.root
end

Rails.application.config.after_initialize do
  # Ensure that valid_child_concerns are set with all the curation concerns including
  # the ones registered from the Knapsack
  Hyrax.config.curation_concerns.each do |concern|
    "#{concern}Resource".safe_constantize&.valid_child_concerns = Hyrax.config.curation_concerns
  end
end
