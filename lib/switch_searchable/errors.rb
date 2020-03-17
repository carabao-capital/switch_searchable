# frozen_string_literal: true

module SwitchSearchable
  module Searchable
    class Errors; end
    class BadDataTypeError < Errors; end
    class RequiredMethodNotDefinedError < Errors; end
  end
end
