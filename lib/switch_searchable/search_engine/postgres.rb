# frozen_string_literal: true

require "pg_search"
require "switch_searchable/search_engine/base"

module SwitchSearchable
  module SearchEngine
    module Postgres
      extend ActiveSupport::Concern
      include Base

      class_methods do
        def init_search_engine(*names)
          trigram_threshold = { using: { trigram: {
            threshold: 0.05
          } } }

          # there should only be one Hash in *names
          associated_against = nil
          against = names.flatten.inject([]) do |array, value|
            if value.is_a? Symbol
              array << value
            elsif value.is_a? Hash
              associated_against = value
            end

            array
          end

          pg_search_scope(:pg_search, {
            against: against,
            associated_against: associated_against,
          }.merge(trigram_threshold))
        end

        def search(term)
          pg_search(term)
        end

        def reindex_search_engine!; end
      end
    end
  end
end
