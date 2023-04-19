# frozen_string_literal: true

module Derivative
  module Rodeo
    module Step
      ##
      # This step is responsible for ensuring that we have the original page file.
      class PageImageStep < BaseStep
        self.prerequisites = []

        def generate
          arena.local_demand_path_for!(derivative: to_sym)
        end
      end
    end
  end
end
