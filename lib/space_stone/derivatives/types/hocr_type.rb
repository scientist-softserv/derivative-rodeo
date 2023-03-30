# frozen_string_literal: true

module SpaceStone
  module Derivatives
    module Types
      ##
      # Responsible for finding or creating a hocr file (or configured :output_base) using
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
        #   SpaceStone::Derivatives::Types::HocrType.command_environment_variables = "OMP_THREAD_LIMIT=1"
        class_attribute :command_environment_variables, default: nil
        # @!attribute [rw]
        # Additional options to send to tesseract command; default `nil`.
        class_attribute :additional_tessearct_options, default: nil
        # @!attribute [rw]
        # The tesseract command's output base; default `:hocr`.
        class_attribute :output_base, default: :hocr
        # @!endgroup

        def pre_process!(manifest:, repository:, **kwargs)
          repository.local_path_for(identifier: manifest.identifier, derivative: to_sym).presence ||
            create_derivative_for(manifest: manifest, repository: repository, **kwargs)
        end

        private

        def create_derivative_for(manifest:, repository:, tmpdir: Dir.mktmpdir)
          monochrome_path = repository.local_path_for!(identifier: manifest.identifier, derivative: :monochrome)

          output_prefix = File.join(tmpdir, "output_html")

          cmd = ""
          cmd += command_environment_variables + " " if command_environment_variables.present?
          cmd += "tesseract #{monochrome_path} #{output_prefix}"
          cmd += " #{additional_tessearct_options}" if additional_tessearct_options.present?
          cmd += " #{output_base}"

          # TODO: What about error handling?
          `#{cmd}`

          repository.put(identifier: manifest.identifier, derivative: to_sym, path: "#{output_prefix}.#{output_base}")
        end
      end
    end
  end
end
