# frozen_string_literal: true

require "switch_searchable/errors"

module SwitchSearchable
  module SearchEngine
    module Base
      extend ActiveSupport::Concern

      class_methods do
        def search(term)
          raise(RequiredMethodNotDefinedError, ":search method not defined in your search engine")
        end

        def reindex_search_engine!
          raise(RequiredMethodNotDefinedError, ":reindex_search_engine! method not defined in your search engine")
        end
        alias reindex! reindex_search_engine!

        def init_search_engine(names)
          raise(RequiredMethodNotDefinedError, ":init_search_engine method not defined in your search engine")
        end

        def searchable_attributes(*names)
          init_search_engine(names)
        end
      end
    end
  end
end
