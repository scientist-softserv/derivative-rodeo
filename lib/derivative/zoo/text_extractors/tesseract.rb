# frozen_string_literal: true
module Derivative
  module Zoo
    module TextExtractors
      ##
      # Responsible for running tesseract on a file at the given path.
      #
      # @see .call
      # @see http://tesseract-ocr.github.io
      #
      # From `tesseract -h`
      #
      #   Usage:
      #     tesseract --help | --help-extra | --version
      #     tesseract --list-langs
      #     tesseract imagename outputbase [options...] [configfile...]
      class Tesseract
        # @!group Class Attributes
        # @!attribute [rw]
        # Command environment variables to for tesseract command; default `nil`.
        #
        # @example
        #   Derivative::Zoo::TextExtractors::Tesseract.command_environment_variables = "OMP_THREAD_LIMIT=1"
        class_attribute :command_environment_variables, default: nil
        # @!attribute [rw]
        # Additional options to send to tesseract command; default `nil`.
        class_attribute :additional_tessearct_options, default: nil
        # @!attribute [rw]
        # The tesseract command's output base; default `:hocr`.
        class_attribute :output_base, default: :hocr
        # @!endgroup

        ##
        # @api public
        #
        # @param path [String]
        #
        # @return [String] path to the file with given {.output_base} extension.
        def self.call(path:)
          new(path: path).call
        end

        def initialize(path:, tmpdir: Dir.mktmpdir)
          @path = path
          @tmpdir = tmpdir
          @output_prefix = File.join(Dir.mktmpdir, 'output_html')
        end
        attr_reader :path, :tmpdir, :output_prefix

        def call
          # TODO: What about error handling?
          `#{cli_command}`
          "#{output_prefix}.#{output_base}"
        end

        private

        def cli_command
          cmd = ""
          cmd += command_environment_variables + " " if command_environment_variables.present?
          cmd += "tesseract #{path} #{output_prefix}"
          cmd += " #{additional_tessearct_options}" if additional_tessearct_options.present?
          cmd += " #{output_base}"
          cmd
        end
      end
    end
  end
end
