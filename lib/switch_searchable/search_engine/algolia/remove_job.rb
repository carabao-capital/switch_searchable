# frozen_string_literal: true

require "switch_searchable/search_engine/algolia/base_job"

module SwitchSearchable
  module SearchEngine
    module Algolia
      class RemoveJob < BaseJob
        def perform(index_name, id)
          index = ::Algolia::Index.new(index_name)
          index.delete_object(id)
        end
      end
    end
  end
end
