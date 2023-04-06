# frozen_string_literal: true

module SpaceStone
  module Derivatives
    module Types
      ##
      class OriginalType < BaseType
        self.prerequisites = []

        def generate
          return environment.local_path(derivative: to_sym) if environment.local_exists?(derivative: to_sym)

          environment.remote_pull!(derivative: to_sym)
        end
      end
    end
  end
end
