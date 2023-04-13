# frozen_string_literal: true

module Derivative
  module Rodeo
    module Step
      ##
      # Responsible for finding or creating a hocr file (or configured :output_suffix) using
      # tesseract.
      #
      # @see http://tesseract-ocr.github.io
      #
      # From `tesseract -h`
      #
      #   Usage:
      #     tesseract --help | --help-extra | --version
      #     tesseract --list-langs
      #     tesseract imagename outputbase [options...] [configfile...]
      class HocrStep < BaseStep
        self.prerequisites = [:monochrome]

        ##
        # @!group Class Attributes
        # @!attribute [rw]
        # Command arena variables to for tesseract command; default `nil`.
        #
        # @example
        #   Derivative::Rodeo::Step::HocrStep.command_environment_variables = "OMP_THREAD_LIMIT=1"
        class_attribute :command_environment_variables, default: nil

        ##
        # @!attribute [rw]
        # Additional options to send to tesseract command; default `nil`.
        class_attribute :additional_tessearct_options, default: nil

        ##
        # @!attribute [rw]
        # The tesseract command's output base; default `:hocr`.
        class_attribute :output_suffix, default: :hocr
        # @!endgroup

        ##
<<<<<<< HEAD
        # @raise [Exceptions::DerivativeNotFoundError] when we don't have a :monochrome {Step} or
=======
        # @raise [Exceptions::DerivativeNotFoundError] when we don't have a :monochrome {Steps} or
>>>>>>> 990c224 (Renaming Type to Step)
        #        we failed to generate the :hocr file.
        def generate
          monochrome_path = arena.local_demand!(derivative: :monochrome)

          # I'm assuming that if the arena returns a local path for a filename, then the
          # process can write a file to the same directory as the returned filename.  Because
          # tesseract takes a base name (e.g. base-hocr) and writes "base-hocr.hocr".
          output_prefix = arena.local_path(derivative: to_sym, filename: "output_html")

          cmd = ""
          cmd += command_environment_variables + " " if command_environment_variables.present?
          cmd += "tesseract #{monochrome_path} #{output_prefix}"
          cmd += " #{additional_tessearct_options}" if additional_tessearct_options.present?
          cmd += " #{output_suffix}"

          local_run_command!(cmd)

          arena.local_assign!(derivative: to_sym, path: "#{output_prefix}.#{output_suffix}")
        end
      end
    end
  end
end
