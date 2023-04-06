# frozen_string_literal: true

module SpaceStone
  module Derivatives
    module Types
      # The :pdf_split derivative processes one file and creates additional files which have some
      # behavior similar to originals in that they have their own processing chain.
      class PdfSplitType < BaseType
        self.prerequisites = []

        # @!group Class Attributes
        # @!attribute [rw]
        class_attribute :page_splitting_service, default: nil
        # @!attribute [rw]
        #
        # When we split the PDFs what are the derivatives we want to run on the resulting individual
        # pages.
        class_attribute :derivative_types_for_split, default: [:ocr]
        # @!endgroup Class Attributes

        # @param repository [SpaceStone::Derivatives::Repository]
        def generate_for(repository:)
          # TODO: What follows is pseudo code as I think about the file processing and necessary
          # interfaces.

          # original_path = repository.demand_local_for!(derivative: original)

          # # If the original is not a PDF nor an image, bail.  If it is a PDF, split it.
          # return unless repository.mime_type(derivative: original).pdf?

          # pages = page_splitting_service.new(
          #   path: original_path,
          #   directory: repository.local_path(derivative: self)
          # )

          # pages.each_with_index do |page, index|
          #   # Make sure that we write page to the derivative's index.
          #   repository.local_assign(derivative: self, index: index, path: page.path)

          #   repository.demand_local_for!(derivative: self, index: index)

          #   # With the pages split, we now should now move along and let the repository run
          #   # derivatives on the split pages.
          #   repository.enqueue(source: self,
          #                      derivatives: derivative_types_for_split,
          #                      index: index)
        end
      end
    end
  end
end
