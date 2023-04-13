# frozen_string_literal: true

module Derivative
  module Rodeo
    module Step
      ##
      #
      class OriginalStep < BaseStep
        self.prerequisites = []

        def generate
          return arena.local_path(derivative: to_sym) if arena.local_exists?(derivative: to_sym)

          arena.remote_pull!(derivative: to_sym)
        end
      end
    end
  end
end
