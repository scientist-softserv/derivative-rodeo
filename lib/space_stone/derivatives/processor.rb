# frozen_string_literal: true

require 'space_stone/derivatives/repository'
require 'space_stone/derivatives/chain'
require 'space_stone/derivatives/processes/base'
require 'space_stone/derivatives/processes/pre_process'

module SpaceStone
  module Derivatives
    ##
    # This class is responsible for processing the given :manifest by dispatching the :process to
    # each derivative of the {Chain}.
    #
    # @see .call
    # @see SpaceStone::Derivatives.pre_process_derivatives_for
    class Processor
      ##
      # @param manifest [Manifest]
      # @param process [Symbol]
      def self.call(manifest:, process:)
        process = "SpaceStone::Derivatives::Processes::#{process.classify}".constantize
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
                     chain: Chain.new(derivatives: manifest.derivatives))
        @repository = repository
        @chain = chain
        @process = process
      end
      attr_reader :chain, :repository, :process

      def call
        chain.each do |derivative|
          process.call(repository: repository, derivative: derivative)
        end
      end
    end
  end
end
