# frozen_string_literal: true
module SpaceStone
  module Derivatives
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
        class_attribute :command_environment_variables, default: nil
        class_attribute :additional_tessearct_options, default: nil
        class_attribute :output_base, default: :hocr

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
          cmd += " hocr"
          cmd
        end
      end
    end
  end
end
