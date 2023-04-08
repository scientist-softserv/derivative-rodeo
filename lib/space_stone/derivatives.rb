# frozen_string_literal: true

require_relative 'derivatives/version'

# Including some of the often expected behavior of the nearly ubiquitious ActiveSupport.
require 'active_support'
require 'active_support/core_ext'

####################################################################################################
####################################################################################################
#
# Hi!  What's with the big comment banner?  I wanted to help you, code-reader, to see that these
# requires are conceptually important.  These are the primary named concepts of
# SpaceStone::Derivatives.  If you are to read them, you should get a good overview of the
# components of SpaceStone::Derivatives.
#
####################################################################################################
####################################################################################################
require 'space_stone/derivatives/configuration'
require 'space_stone/derivatives/environment'
require 'space_stone/derivatives/exceptions'
require 'space_stone/derivatives/manifest'
require 'space_stone/derivatives/process'
require 'space_stone/derivatives/queue_adapters'
require 'space_stone/derivatives/storage_adapters'
require 'space_stone/derivatives/type'

# These are the files conceptually lifted from the IIIF Print gem; they are of secondary concern.
# And will slowly be moved elsewhere.
require 'space_stone/derivatives/pdf_pages_summary'
require 'space_stone/derivatives/technical_metadata'
require 'space_stone/derivatives/page_splitters'
require 'space_stone/derivatives/text_extractors'
require 'space_stone/derivatives/utilities'

module SpaceStone
  ##
  # Welcome to SpaceStone::Derivatives, a gem responsible for coordinating the generation and
  # "movement" of derivatives from one environment to another.
  #
  # @see .config
  # @see .start_pre_processing!
  module Derivatives
    ##
    # The {Configuration} that the various processes in your implementation will use.
    #
    # @api public
    #
    # @yieldparam [SpaceStone::Derivatives::Configuration]
    # @return [SpaceStone::Derivatives::Configuration]
    def self.config
      @config ||= Configuration.new
      yield(@config) if block_given?
      @config
    end

    ##
    # @api public
    #
    # For the given :manifest, run the pre-process tasks.
    #
    # @param manifest [SpaceStone::Derivatives::Manifest::PreProcess]
    # @param config [SpaceStone::Derivatives::Configuration]
    #
    # @return [SpaceStone::Derivatives::Environment]
    #
    # @see SpaceStone::Derivatives::Environment
    def self.start_pre_processing!(manifest:, config: Derivatives.config)
      Environment.for_pre_processing(manifest: manifest, config: config, &:start_processing!)
    end
  end
end
