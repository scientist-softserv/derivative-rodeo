# frozen_string_literal: true

module SpaceStone
  module Derivatives
    module Type
      # The :pdf_split derivative processes one file and creates additional files which have some
      # behavior similar to originals in that they have their own processing chain.
      class PdfSplitType < BaseType
        self.prerequisites = []
        self.spawns = [:ocr]

        # @!group Class Attributes
        # @!attribute [rw]
        class_attribute :page_splitting_service, default: nil
        # @!attribute [rw]
        #
        # When we split the PDFs what are the derivatives we want to run on the resulting individual
        # pages.
        class_attribute :derivative_types_for_split, default: [:ocr]
        # @!endgroup Class Attributes

        def generate
          # generate do
          #   return unless mime_type(derivative: original).pdf?
          #   pages = page_splitting_service.new(environment: environment)
          #   pages.each_with_index do |page, index|
          #     derived = Spaces::Derivative::Manifest::Derived.new(original: environment.manifest, derived: :pdf_page, index: index)
          #     derived_environment = Spaces::Derivatives::Environment.for_derived(manifest: derived, envrionment: environment)
          #     derived_environment.local_assign!(derivative: :pdf_page, path: page)
          #     derivatives.process_start!
          #   end
          # end
        end
      end
    end
  end
end
