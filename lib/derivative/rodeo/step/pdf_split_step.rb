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

        ##
        # @!attribute [rw]
        # @return [Symbol, #to_sym]
        #
        # This step will be working on a parent chain, with a directory likely to be
        # `<work_identifier>/<file_set_filename>` (see
        # {Manifest::PreProcess::Identifier#directory_slugs}).  In that directory will be a file
        # `base_file_for_chain`; that will be the original PDF file.
        #
        # When we split the PDFs we will write each page to the follow path, relative to the parent:
        #  `<first_spawn_step_name>/<index>/base_file_for_chain`
        #
        # The first_spawn_step_name will be the first step in the split chain, and is responsible
        # for ensuring that the split chain has the page image for later processing (e.g. :page_ocr)
        class_attribute :first_spawn_step_name, default: :page_image, instance_writer: false

        ##
        # In this case the base_file_for_chain likely represents that original PDF.
        self.prerequisites = [:base_file_for_chain]
        self.spawns = [first_spawn_step_name, :page_ocr]
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

          # We need to write the file to the :page_image
          pdf_splitter.call(path_to_original).each_with_index do |path, index|
            process_page_split!(path: path, index: index)
          end
        end

        private

        def process_page_split!(path:, index:)
          derived_arena = Derivative::Rodeo::Arena.for_derived(
            parent_arena: arena,
            path_to_base_file_for_chain: path,
            first_spawn_step_name: first_spawn_step_name.to_sym,
            index: index,
            derivatives: spawns
          )
          derived_arena.start_processing!
        end
      end
    end
  end
end
