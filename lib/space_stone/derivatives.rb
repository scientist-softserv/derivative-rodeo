# frozen_string_literal: true

require_relative 'derivatives/version'
require 'active_support'
require 'space_stone/derivatives/exceptions'
require 'space_stone/derivatives/manifest'
require 'space_stone/derivatives/processor'
require 'space_stone/derivatives/storage_adapters'

# These are the files conceptually lifted from the IIIF Print gem.
require 'space_stone/derivatives/pdf_pages_summary'
require 'space_stone/derivatives/technical_metadata'
require 'space_stone/derivatives/page_splitters'
require 'space_stone/derivatives/text_extractors'
require 'space_stone/derivatives/utilities'

module SpaceStone
  ##
  # Welcome to SpaceStone::Derivatives, a gem responsible
  module Derivatives
    def self.logger
      # For testing I really want to set a Logger::FATAL level so I'm not seeing all of the chatter.
      @logger ||= Logger.new(STDERR, level: Logger::FATAL)
    end

    ##
    # @api public
    #
    # The function will take the given :manifest and ensure that each name derivative is stored in a
    # predictable location.  The :process will attempt to re-use an existing derivative, and failing
    # that will create the derivative.
    #
    # @param manifest [SpaceStone::Derivatives::Manifest::Original]
    # @param process [Sybmol]
    #
    # @see Manifest::LocationSet
    def self.pre_process_derivatives_for(manifest:, process: :pre_process)
      Processor.call(manifest: manifest, process: process)
    end

    ##
    # @api public
    #
    # @param manifest [SpaceStone::Derivatives::Manifest::Original]
    #
    # @return [Manifest::LocationSet]
    def self.get_file_locators_for(manifest:)
      # FileLocator.new(manifest: manifest).call
    end
  end
end
