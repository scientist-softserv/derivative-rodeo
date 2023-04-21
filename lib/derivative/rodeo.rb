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
require 'derivative/rodeo/invocation'
require 'derivative/rodeo/manifest'
require 'derivative/rodeo/process'
require 'derivative/rodeo/queue_adapters'
require 'derivative/rodeo/storage_adapters'
require 'derivative/rodeo/step'
require 'derivative/rodeo/utilities'

# These are the files conceptually lifted from the IIIF Print gem; they are of secondary concern.
# And will slowly be moved elsewhere.
require 'derivative/rodeo/pdf_pages_summary'
require 'derivative/rodeo/technical_metadata'
require 'derivative/rodeo/text_extractors'

module Derivative
  ##
  # Welcome to Derivative::Rodeo, a gem responsible for coordinating the generation and
  # "movement" of derivatives from one arena to another.
  #
  # @see .config
  # @see .process_derivative
  # @see .process_file_sets_from_csv
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
    # Process a singular derivative for the given json message.
    #
    # @param json [String] a JSON string that provides an {Arena} the context to process the encoded
    #        deriative.
    # @param config [Derivative::Rodeo::Configuration]
    #
    # @return [Derivative::Rodeo::Arena]
    # @see Arena#process_derivatives!
    # @see Arena.from_json
    def self.process_derivative(json:, config: Rodeo.config)
      # TODO: Consider reworking to:
      # Invocation.invoke(:process_derivative, body: json, config: config)
      Arena.from_json(json, config: config, &:process_derivative!)
    end

    ##
    # Process a CSV with one row representing one {Manifest::PreProcess}.
    #
    # @param body [String] the CSV
    # @param config [Derivative::Rodeo::Configuration]
    #
    # @see Invocation
    #
    # @see https://github.com/scientist-softserv/adventist-dl/issues/369 Acceptance criteria
    def self. process_file_sets_from_csv(body, config: Rodeo.config)
      Invocation.invoke(:process_file_sets_from_csv, body: body, config: config)
    end
  end
end
