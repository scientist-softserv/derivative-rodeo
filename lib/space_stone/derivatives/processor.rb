# frozen_string_literal: true

require 'space_stone/derivatives/repository'
require 'space_stone/derivatives/chain'

module SpaceStone
  module Derivatives
    ##
    # This class is responsible for processing the given :manifest by dispatching the :command to
    # each derivative of the {Chain}.
    #
    # @see .call
    # @see SpaceStone::Derivatives.pre_process_derivatives_for
    class Processor
      ##
      # @param manifest [Manifest]
      # @param command [Symbol]
      def self.call(manifest:, command:)
        new(manifest: manifest, command: command).call
      end

      def initialize(manifest:,
                     command: :pre_process!,
                     repository: Repository.new(manifest: manifest),
                     chain: Chain.new(derivatives: manifest.derivatives))
        @repository = repository
        @chain = chain
        @command = command
      end
      attr_reader :chain, :repository, :command

      def call
        chain.each do |derivative|
          derivative.send(command, repository: repository)
        end
      end
    end
  end
end
