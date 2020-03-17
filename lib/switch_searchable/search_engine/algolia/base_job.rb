# frozen_string_literal: true

require "active_job"

module SwitchSearchable
  module SearchEngine
    module Algolia
      class BaseJob < ::ApplicationJob
        queue_as :algolia
        retry_on ::Algolia::AlgoliaError
        discard_on ActiveRecord::RecordNotFound
      end
    end
  end
end
