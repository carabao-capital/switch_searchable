module SwitchSearchable
  module SearchEngine
    module Postgres
      class BadConfiguration < StandardError; end

      class << self
        def included(klass)
          raise_errors

          klass.class_eval do
            extend ClassMethods
            include PgSearch
          end
        end

        def raise_errors; end

        module ClassMethods
          def init_search_engine(*names)
            trigram_threshold = {using: {trigram: {
              threshold: 0.05
            }}}

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
end
