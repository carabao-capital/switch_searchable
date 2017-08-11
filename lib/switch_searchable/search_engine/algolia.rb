module SwitchSearchable
  module SearchEngine
    module Algolia
      class BadConfiguration < StandardError; end
      class RequiredMethodNotDefined < StandardError; end

      class << self
        def included(klass)
          raise_errors

          klass.class_eval do
            extend ClassMethods
            include AlgoliaSearch
          end
        end

        def raise_errors
          raise(
            BadConfiguration,
            "Please add ALGOLIA_APP_ID in your environment variables"
          ) unless ENV["ALGOLIA_APP_ID"]

          raise(
            BadConfiguration,
            "Please add ALGOLIA_API_KEY in your environment variables"
          ) unless ENV["ALGOLIA_APP_ID"]

          raise(
            BadConfiguration,
            "Please add ALGOLIA_ENVIRONMENT in your environment variables"
          ) unless ENV["ALGOLIA_ENVIRONMENT"]
        end

        module ClassMethods
          def init_search_engine(*names)
            algoliasearch index_name: "#{self.to_s}_#{ENV["ALGOLIA_ENVIRONMENT"]}" do
              names.flatten.each do |name|
                if name.is_a? Symbol
                  attribute(name)
                elsif name.is_a? Hash
                  name.keys.each do |key|
                    array = name[key]
                    raise(
                      BadDataType,
                      "searchable_attributes associations can only have Array"
                    ) unless array.is_a? Array

                    attribute(key) do
                      value = send(key)
                      unless value.blank?
                        if value.respond_to? :to_a
                          value.map do |v|
                            array.inject({}) do |hash, element|
                              raise(
                                BadDataType,
                                "searchable_attributes associations
                                attributes can only have Symbol"
                              ) unless array.is_a? Array

                              hash[element] = v.send(element)
                            end
                          end
                        else
                          array.inject({}) do |hash, element|
                            raise(
                              BadDataType,
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
                    BadDataType,
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
        end
      end
    end
  end
end
