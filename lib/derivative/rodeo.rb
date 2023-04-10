# frozen_string_literal: true

require_relative 'rodeo/version'

# Including some of the often expected behavior of the nearly ubiquitious ActiveSupport.
require 'active_support'
require 'active_support/core_ext'

####################################################################################################
####################################################################################################
#
# Hi!  What's with the big comment banner?  I wanted to help you, code-reader, to see that these
# requires are conceptually important.  These are the primary named concepts of
# Derivative::Rodeo.  If you are to read them, you should get a good overview of the
# components of Derivative::Rodeo.
#
####################################################################################################
####################################################################################################
require 'derivative/rodeo/configuration'
require 'derivative/rodeo/dry_run'
require 'derivative/rodeo/arena'
require 'derivative/rodeo/exceptions'
require 'derivative/rodeo/manifest'
require 'derivative/rodeo/message'
require 'derivative/rodeo/process'
require 'derivative/rodeo/queue_adapters'
require 'derivative/rodeo/storage_adapters'
require 'derivative/rodeo/type'

# These are the files conceptually lifted from the IIIF Print gem; they are of secondary concern.
# And will slowly be moved elsewhere.
require 'derivative/rodeo/pdf_pages_summary'
require 'derivative/rodeo/technical_metadata'
require 'derivative/rodeo/page_splitters'
require 'derivative/rodeo/text_extractors'
require 'derivative/rodeo/utilities'

module Derivative
  ##
  # Welcome to Derivative::Rodeo, a gem responsible for coordinating the generation and
  # "movement" of derivatives from one arena to another.
  #
  # @see .config
  # @see .start_pre_processing!
  module Rodeo
    ##
    # The {Configuration} that the various processes in your implementation will use.
    #
    # @api public
    #
    # @yieldparam [Derivative::Rodeo::Configuration]
    # @return [Derivative::Rodeo::Configuration]
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
    # @param manifest [Derivative::Rodeo::Manifest::PreProcess]
    # @param config [Derivative::Rodeo::Configuration]
    #
    # @return [Derivative::Rodeo::Arena]
    def self.start_pre_processing(manifest:, config: Rodeo.config)
      Arena.for_pre_processing(manifest: manifest, config: config, &:start_processing!)
    end
  end
end
