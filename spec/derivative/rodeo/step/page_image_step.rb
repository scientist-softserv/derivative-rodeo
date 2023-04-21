# frozen_string_literal: true

module Derivative
  module Rodeo
    module Step
      ##
      # This step is responsible for ensuring that we have the original page file.
      class PageImageStep < BaseStep
        self.prerequisites = []

        ##
        # The {PageImageStep} is the first step from the spawning of the {PdfSplitStep}.  As per
        # convention, that means it's associated file is `base_file_for_chain`.
        #
        # @param storage [StorageAdapters::Base]
        # @see PdfSplitStep
        def self.demand_path_for!(storage:)
          storage.demand_path_for!(derivative: :base_file_for_chain)
        end
        # rubocop:enable Lint/UnusedMethodArgument

        ##
        # @note
        #   This should already have been generated as part of the {SplitPdfStep}
        def generate
          arena.local_demand_path_for!(derivative: to_sym)
        end
      end
    end
  end
end
