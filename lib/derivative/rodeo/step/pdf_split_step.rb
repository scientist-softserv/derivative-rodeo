# frozen_string_literal: true

module Derivative
  module Rodeo
    module Step
      ##
      # The :pdf_split derivative processes one file and creates additional files which have some
      # behavior similar to originals in that they have their own processing chain.
      class PdfSplitStep < BaseStep
        ##
        # @!group Class Attributes
        # @!attribute [rw]
        # @return [#call]
        #
        # The call function should receive a string and return an Enumerable that yields the page's
        # path.
        #
        # @see #generate
        class_attribute :pdf_splitter_name, default: :tiff
        class_attribute :derived_original_name, default: :page_image, instance_writer: false

        self.prerequisites = [:base_file_for_chain]
        self.spawns = [derived_original_name, :page_ocr]
        # @!endgroup Class Attributes

        ##
        # @return [#call, Utilities::PdfSplitter::Base]
        def pdf_splitter
          @pdf_splitter ||= Utilities::PdfSplitter.for(pdf_splitter_name)
        end

        ##
        # @api private
        #
        # @note Provided as a convenience method for testing.
        attr_writer :pdf_splitter

        def generate
          path_to_original = arena.local_path_for_shell_commands(derivative: :original)

          pdf_splitter.call(path_to_original).each_with_index do |path, index|
            process_page_split!(path: path, index: index)
          end
        end

        private

        def process_page_split!(path:, index:)
          derived_arena = Derivative::Rodeo::Arena.for_derived(
            parent_arena: arena,
            derived_original_path: path,
            derived_original_name: derived_original_name.to_sym,
            index: index,
            derivatives: spawns
          )
          derived_arena.start_processing!
        end
      end
    end
  end
end
