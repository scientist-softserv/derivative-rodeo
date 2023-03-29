# frozen_string_literal: true

module SpaceStone
  module Derivatives
    ##
    # This class is responsible for processing the given :manifest by dispatching the sending the
    # derivatives the :pre_process! message.
    #
    # @see .call
    # @see SpaceStone::Derivatives.pre_process_derivatives_for
    class PreProcessor
      ##
      # @param manifest [Manifest]
      def self.call(manifest:)
        new(manifest: manifest).call
      end

      def initialize(manifest:, chain: Chain.new(derivatives: manifest.derivatives))
        @manifest = manifest
        # TODO: Replace this with something
        @repository = :repository
        @chain = chain
      end
      attr_reader :manifest, :chain, :repository

      def call
        chain.each do |derivative|
          derivative.pre_process!(manifest: manifest, repository: repository)
        end
      end
    end
  end
end
