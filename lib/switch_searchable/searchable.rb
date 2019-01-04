module SwitchSearchable
  module Searchable
    class BadConfiguration < StandardError; end
    class RequiredMethodNotDefined < StandardError; end

    class << self
      def included(klass)
        check_config

        klass.class_eval do
          extend ClassMethods

          if Rails.env.production?
            include "SwitchSearchable::SearchEngine::Algolia".
              constantize
          else
            include "SwitchSearchable::SearchEngine::Postgres".
              constantize
          end
        end

        check_methods(klass)
      end

      def check_config
        raise(
          BadConfiguration,
          "Please add SEARCH_ENGINE in your environment variables"
        ) unless search_engine_default_local
      end

      def check_methods(klass)
        raise(
          RequiredMethodNotDefined,
          ":raise_errors method not defined in your search engine"
        ) unless "SwitchSearchable::SearchEngine::#{search_engine_default_local}".
          constantize.respond_to? :raise_errors

        raise(
          RequiredMethodNotDefined,
          ":search method not defined in your search engine"
        ) unless klass.respond_to? :search

        raise(
          RequiredMethodNotDefined,
          ":reindex_search_engine! method not defined in your search engine"
        ) unless klass.respond_to? :reindex_search_engine!

        raise(
          RequiredMethodNotDefined,
          ":init_search_engine method not defined in your search engine"
        ) unless klass.respond_to? :init_search_engine
      end

      module ClassMethods
        def searchable_attributes(*names)
          init_search_engine(names)
        end

        def search(term)
          "SwitchSearchable::SearchEngine::#{ENV["SEARCH_ENGINE"]}".
            constantize.search(term)
        end

        def reindex!
          reindex_search_engine!
        end
      end

      private

      def search_engine_default_local
        ENV["SEARCH_ENGINE"] || "Postgres"
      end
    end
  end
end
