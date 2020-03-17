# frozen_string_literal: true

require "active_support/concern"

module SwitchSearchable
  module Searchable
    extend ActiveSupport::Concern

    included do
      case ENV["SEARCH_ENGINE"].downcase
      when "algolia"
        require "switch_searchable/search_engine/algolia"

        include AlgoliaSearch
        include SearchEngine::Algolia
      when "elasticsearch"
        require "switch_searchable/search_engine/elasticsearch"

        include Elasticsearch::Model
        include Elasticsearch::Model::Callbacks
        include SearchEngine::Elasticsearch
      else
        require "switch_searchable/search_engine/postgres"

        include PgSearch
        include SearchEngine::Postgres
      end
    end
  end
end
