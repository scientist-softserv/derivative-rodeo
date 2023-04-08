# frozen_string_literal: true
require 'marcel'

module SpaceStone
  module Derivatives
    module Type
      class MimeType < BaseType
        self.prerequisites = [:original]

        def generate
          content = environment.local_read(derivative: :original)
          environment.mime_type ||= ::Marcel::MimeType.for(content)

          SpaceStone::Derivatives::Environment.start_processing_for_mime_type!(environment: environment)
        end
      end
    end
  end
end
