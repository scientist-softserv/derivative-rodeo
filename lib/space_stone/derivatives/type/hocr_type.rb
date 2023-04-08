# frozen_string_literal: true

module SpaceStone
  module Derivatives
    module Type
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
      class HocrType < BaseType
        self.prerequisites = [:monochrome]

        # @!group Class Attributes
        # @!attribute [rw]
        # Command environment variables to for tesseract command; default `nil`.
        #
        # @example
        #   SpaceStone::Derivatives::Type::HocrType.command_environment_variables = "OMP_THREAD_LIMIT=1"
        class_attribute :command_environment_variables, default: nil
        # @!attribute [rw]
        # Additional options to send to tesseract command; default `nil`.
        class_attribute :additional_tessearct_options, default: nil
        # @!attribute [rw]
        # The tesseract command's output base; default `:hocr`.
        class_attribute :output_suffix, default: :hocr
        # @!endgroup

        # @raise [Exceptions::DerivativeNotFoundError] when we don't have a :monochrome {Types} or
        #        we failed to generate the :hocr file.
        def generate
          monochrome_path = environment.local_demand!(derivative: :monochrome)

          # I'm assuming that if the environment returns a local path for a filename, then the
          # process can write a file to the same directory as the returned filename.  Because
          # tesseract takes a base name (e.g. base-hocr) and writes "base-hocr.hocr".
          output_prefix = environment.local_path(derivative: to_sym, filename: "output_html")

          cmd = ""
          cmd += command_environment_variables + " " if command_environment_variables.present?
          cmd += "tesseract #{monochrome_path} #{output_prefix}"
          cmd += " #{additional_tessearct_options}" if additional_tessearct_options.present?
          cmd += " #{output_suffix}"

          local_run_command!(cmd)

          environment.local_assign!(derivative: to_sym, path: "#{output_prefix}.#{output_suffix}")
        end
      end
    end
  end
end
