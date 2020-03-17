# frozen_string_literal: true

require "switch_searchable/search_engine/algolia/base_job"

module SwitchSearchable
  module SearchEngine
    module Algolia
      class IndexJob < BaseJob
        def perform(klass_name, id)
          record = klass_name.constantize.find(id)
          record.index!
        end
      end
    end
  end
end
