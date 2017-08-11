module SwitchSearchable
  module SearchEngine
    module Elasticsearch
      class BadConfiguration < StandardError; end
      class BadDataType < StandardError; end

      class << self
        def included(klass)
          raise_errors

          klass.class_eval do
            extend ClassMethods
            include ::Elasticsearch::Model
            include ::Elasticsearch::Model::Callbacks
          end
        end

        def raise_errors
          raise(
            BadConfiguration,
            "Please add ELASTICSEARCH_HOST in your environment variables"
          ) unless ENV["ELASTICSEARCH_HOST"]
        end

        module ClassMethods
          def init_search_engine(*names)
            index_name Rails.application.class.parent_name.underscore
            document_type self.name.downcase

            fields = names.flatten.inject([]) do |result_arr, name|
              if name.is_a? Symbol
                result_arr << name
              elsif name.is_a? Hash
                name.keys.each do |key|
                  array = name[key]
                  raise(
                    BadDataType,
                    "searchable_attributes associations can only have Array"
                  ) unless array.is_a? Array

                  result = array.inject([]) do |array, element|
                    raise(
                      BadDataType,
                      "searchable_attributes associations
                      attributes can only have Symbol"
                    ) unless array.is_a? Array

                    array << key.to_s + "." + element.to_s
                  end

                  result_arr << result
                end
              else
                raise(
                  BadDataType,
                  "searchable_attributes can only be either a Symbol or an Hash"
                )
              end

              result_arr.flatten
            end

            define_singleton_method(:call_search) do |term|
              __elasticsearch__.search(
                { query:
                  { multi_match:
                    { query: term, fields: fields}
                  },
                  size: 10000,
                }
              )
            end

            as_indexed_hash = names.flatten.inject({}) do |result_hash, name|
              if name.is_a? Hash
                name.keys.each do |key|
                  array = name[key]
                  raise(
                    BadDataType,
                    "searchable_attributes associations can only have Array"
                  ) unless array.is_a? Array

                  result_hash[key] = { only: array }
                end
              end

              result_hash
            end

            define_method(:as_indexed_json) do |options|
              self.as_json(only: names.flatten, include: as_indexed_hash)
            end
          end

          def search(term)
            connection
            call_search(term).records
          end

          def reindex_search_engine!
            puts "Creating index..."
            __elasticsearch__.create_index! force: true
            __elasticsearch__.refresh_index!
            puts "Importing data..."
            import
          end
        end
      end
    end
  end
end
