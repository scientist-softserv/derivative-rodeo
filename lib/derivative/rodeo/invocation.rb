# frozen_string_literal: true

module Derivative
  module Rodeo
    ##
    # A module space for registering different invocations.
    #
    # What is an invocation?  This relates to how AWS Lambdas run.  Conceptually, it is a named
    # function/process.
    module Invocation
      ##
      # @api public
      # @param invocation [Symbol]
      # @param body [String]
      # @param config [Derivative::Rodeo::Configuration]
      def self.invoke(invocation, body:, config:)
        klass = "Derivative::Rodeo::Invocation::#{invocation.to_s.classify}Invocation".constantize
        klass.new(body: body, config: config).call
      end

      # This module establishes the interface of invocations
      module Base
        extend ActiveSupport::Concern

        class_methods do
          ##
          # @param body [String]
          # @param config [Derivative::Rodeo::Configuration]
          def call(body:, config:)
            new(body: body, config: config).call
          end
        end

        def initialize(body:, config:, queue: config.queue)
          @body = body
          @config = config
          @queue = QueueAdapters.for(adapter: queue)
        end

        attr_reader :body, :config, :queue

        def call
          raise NotImplementedError
        end
      end
    end
  end
end

require 'derivative/rodeo/invocation/process_file_sets_from_csv_invocation'
