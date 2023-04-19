# frozen_string_literal: true

module Derivative
  module Rodeo
    module Step
      ##
      # This step is responsible for ensuring that the original file, as identified in the
      # {Manifest} is available for the rodeo.
      class OriginalStep < BaseStep
        self.prerequisites = []

        def generate
          # TODO: Is this necessary?  I'm wondering if we're already checking.
          return arena.local_path(derivative: to_sym) if arena.local_exists?(derivative: to_sym)

          arena.remote_fetch!(derivative: to_sym)
        end
      end
    end
  end
end
