# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work_resource NewspaperResource`
require 'rails_helper'
require 'hyrax/specs/shared_specs/indexers'

RSpec.describe NewspaperResourceIndexer do
  let(:indexer_class) { described_class }
  let(:resource) { NewspaperResource.new }

  it_behaves_like 'a Hyrax::Resource indexer'
end
