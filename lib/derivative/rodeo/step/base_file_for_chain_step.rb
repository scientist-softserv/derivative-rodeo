# frozen_string_literal: true

module Derivative
  module Rodeo
    module Step
      ##
      # Ensures that for the given {Chain} the base file exists.  We will want the first step of
      # each {Chain} to be `:base_file_for_chain`.
      #
      # In the case where we're starting from an original file (e.g. the thing of primary interest),
      # the :base_file_for_chain will be that original file.  However, when we make a derivative
      # (such as an image from a PDF) we might want to start a new {Chain} and treat that image as
      # the :base_file_for_chain.  See {PdfSplitStep}
      #
      # Whomever instigates the processing, should decide the :base_file_for_chain.
      #
      # Why have this common point?  Because we sometimes rip apart PDFs into Images and want to use
      # similar processing for those images.
      class BaseFileForChainStep < BaseStep
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
