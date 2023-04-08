# frozen_string_literal: true

require_relative 'zoo/version'

# Including some of the often expected behavior of the nearly ubiquitious ActiveSupport.
require 'active_support'
require 'active_support/core_ext'

####################################################################################################
####################################################################################################
#
# Hi!  What's with the big comment banner?  I wanted to help you, code-reader, to see that these
# requires are conceptually important.  These are the primary named concepts of
# Derivative::Zoo.  If you are to read them, you should get a good overview of the
# components of Derivative::Zoo.
#
####################################################################################################
####################################################################################################
require 'derivative/zoo/configuration'
require 'derivative/zoo/dry_run'
require 'derivative/zoo/environment'
require 'derivative/zoo/exceptions'
require 'derivative/zoo/manifest'
require 'derivative/zoo/process'
require 'derivative/zoo/queue_adapters'
require 'derivative/zoo/storage_adapters'
require 'derivative/zoo/type'

# These are the files conceptually lifted from the IIIF Print gem; they are of secondary concern.
# And will slowly be moved elsewhere.
require 'derivative/zoo/pdf_pages_summary'
require 'derivative/zoo/technical_metadata'
require 'derivative/zoo/page_splitters'
require 'derivative/zoo/text_extractors'
require 'derivative/zoo/utilities'

module Derivative
  ##
  # Welcome to Derivative::Zoo, a gem responsible for coordinating the generation and
  # "movement" of derivatives from one environment to another.
  #
  # @see .config
  # @see .start_pre_processing!
  module Zoo
    ##
    # The {Configuration} that the various processes in your implementation will use.
    #
    # @api public
    #
    # @yieldparam [Derivative::Zoo::Configuration]
    # @return [Derivative::Zoo::Configuration]
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
    # @param manifest [Derivative::Zoo::Manifest::PreProcess]
    # @param config [Derivative::Zoo::Configuration]
    #
    # @return [Derivative::Zoo::Environment]
    #
    # @see Derivative::Zoo::Environment
    def self.start_pre_processing!(manifest:, config: Zoo.config)
      Environment.for_pre_processing(manifest: manifest, config: config, &:start_processing!)
    end
  end
end
