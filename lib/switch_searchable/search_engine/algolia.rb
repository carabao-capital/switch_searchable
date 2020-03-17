# frozen_string_literal: true

require "algoliasearch-rails"
require "switch_searchable/search_engine/base"
require "switch_searchable/search_engine/algolia/index_job"
require "switch_searchable/search_engine/algolia/remove_job"

module SwitchSearchable
  module SearchEngine
    module Algolia
      extend ActiveSupport::Concern
      include Base

      class_methods do
        def init_search_engine(*names)
          algoliasearch index_name: search_index_name, enqueue: :trigger_index_job do
            names.flatten.each do |name|
              if name.is_a? Symbol
                attribute(name)
              elsif name.is_a? Hash
                name.keys.each do |key|
                  array = name[key]
                  raise(
                    BadDataTypeError,
                    "searchable_attributes associations can only have Array"
                  ) unless array.is_a? Array

                  attribute(key) do
                    value = send(key)
                    unless value.blank?
                      if value.respond_to? :to_a
                        value.map do |v|
                          array.inject({}) do |hash, element|
                            raise(
                              BadDataTypeError,
                              "searchable_attributes associations
                              attributes can only have Symbol"
                            ) unless array.is_a? Array

                            hash[element] = v.send(element)
                          end
                        end
                      else
                        array.inject({}) do |hash, element|
                          raise(
                            BadDataTypeError,
                            "searchable_attributes associations
                            attributes can only have Symbol"
                          ) unless array.is_a? Array

                          hash[element] = value.send(element)
                        end
                      end
                    end
                  end
                end
              else
                raise(
                  BadDataTypeError,
                  "searchable_attributes can only be
                  either a Symbol or an Array"
                )
              end
            end

            searchable_attrs = names.flatten.map do |name|
              if name.is_a? Hash
                name.keys
              else
                name
              end
            end.flatten

            searchableAttributes(searchable_attrs)
          end
        end

        def search(term)
          algolia_search(term)
        end

        def reindex_search_engine!
          algolia_reindex!
        end

        def trigger_index_job(record, remove)
          return ::SwitchSearchable::SearchEngine::Algolia::RemoveJob.perform_later(search_index_name, record.id) if remove

          ::SwitchSearchable::SearchEngine::Algolia::IndexJob.perform_later(name, record.id)
        end

        def search_index_name; "#{self}_#{ENV["ALGOLIA_ENVIRONMENT"]}"; end
      end
    end
  end
end
