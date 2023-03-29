# frozen_string_literal: true

require_relative 'derivatives/version'
require 'space_stone/derivatives/manifest'
require 'space_stone/derivatives/pdf_pages_summary'
require 'space_stone/derivatives/technical_metadata'
require 'space_stone/derivatives/page_splitters'
require 'space_stone/derivatives/text_extractors'
require 'space_stone/derivatives/utilities'
require 'space_stone/derivatives/contexts'
require 'space_stone/derivatives/pre_processor'
require 'active_support'

module SpaceStone
  module Derivatives
    class Error < StandardError; end

    ##
    # @api public
    #
    # The function will take the given :manifest and ensure that each name derivative is stored in a
    # predictable location.  The process will attempt to re-use an existing derivative, and failing
    # that will create the derivative.
    #
    # @param manifest [Manifest]
    #
    # @see Manifest::LocationSet
    def self.pre_process_derivatives_for(manifest:, processor: PreProcessor)
      processor.call(manifest: manifest)
    end

    ##
    # @api public
    #
    # @param manifest [Manifest]
    #
    # @return [Manifest::LocationSet]
    def self.get_file_locators_for(manifest:)
      # FileLocator.new(manifest: manifest).call
    end
  end
end
