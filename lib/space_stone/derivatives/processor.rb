# frozen_string_literal: true

require 'logger'
require 'space_stone/derivatives/repository'
require 'space_stone/derivatives/chain'
require 'space_stone/derivatives/processes/pre_process'

module SpaceStone
  module Derivatives
    ##
    # This class is responsible for processing the given :manifest with the given :process.
    #
    # @see .call
    # @see SpaceStone::Derivatives.pre_process_derivatives_for
    class Processor
      ##
      #
      # Call the :process for each derivative in the given :manifest's {Chain}
      #
      # @param manifest [Manifest]
      # @param process [Symbol]
      #
      # @raise [NameError] when the given :process is undefined
      #
      # @see #call
      def self.call(manifest:, process:)
        process = "SpaceStone::Derivatives::Processes::#{process.to_s.classify}".constantize
        new(manifest: manifest, process: process).call
      end

      ##
      # @param manifest [Manifest]
      # @param process [Processors::BaseProcessor, #call]
      # @param repository [Repository]
      # @param chain [Chain, #each, Array<Types::BaseType>]
      def initialize(manifest:,
                     process:,
                     repository: Repository.new(manifest: manifest),
                     chain: Chain.new(derivatives: manifest.derivatives),
                     logger: Derivatives.logger)
        @repository = repository
        @chain = chain
        @process = process
        @errors = []
        @logger = logger
      end
      attr_reader :chain, :repository, :process, :errors, :logger

      def call
        chain.each do |derivative|
          logger.info("Begin processing derivative #{derivative.inspect} for repository #{repository.inspect}")
          process.call(repository: repository, derivative: derivative)
          logger.info("Success processing derivative #{derivative.inspect} for repository #{repository.inspect}")
        rescue => e
          logger.error("Error processing derivative #{derivative.inspect} for repository #{repository.inspect}.  Encountered #{e}.")
          @errors << e
        end
        return true unless errors.any?

        raise Exceptions::ProcessorError, process: self, errors: errors
      end
    end
  end
end
