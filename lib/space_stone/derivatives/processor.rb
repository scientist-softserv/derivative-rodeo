# frozen_string_literal: true

module SpaceStone
  module Derivatives
    ##
    # This class is responsible for processing the given :manifest by dispatching the :message to
    # each derivative of the {Chain}.
    #
    # @see .call
    # @see SpaceStone::Derivatives.pre_process_derivatives_for
    class Processor
      ##
      # @param manifest [Manifest]
      # @param message [Symbol]
      def self.call(manifest:, message:)
        new(manifest: manifest, message: message).call
      end

      def initialize(manifest:, message: :pre_process!, chain: Chain.new(derivatives: manifest.derivatives))
        @manifest = manifest
        # TODO: Replace this with something
        @repository = :repository
        @chain = chain
        @message = message
      end
      attr_reader :manifest, :chain, :repository, :message

      def call
        chain.each do |derivative|
          derivative.public_send(message, manifest: manifest, repository: repository)
        end
      end
    end
  end
end
