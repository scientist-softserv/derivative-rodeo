# frozen_string_literal: true

require 'aws-sdk-sqs'

module Derivative
  module Rodeo
    module QueueAdapters
      ##
      # An adapter for leveraging Amazon Web Services Simple Queue Service
      #
      # @see https://github.com/scientist-softserv/space_stone/blob/c433a4e38b9acac335abaa18daa33dcf0d22aeb4/lib/space_stone/sqs_service.rb Prior art in SpaceStone
      # @see https://rubygems.org/gems/aws-sdk-sqs  Aws::SQS gem
      class AwsSqsAdapter
        include QueueAdapters::Base

        # @!group Class Attributes
        #
        # @!attribute [rw]
        # The name of the region in which we're processing.
        # @return [String]
        # @see .client
        class_attribute :region, default: 'us-east-2', instance_writer: false

        # @!attribute [rw]
        # The name of the queue we're enqueing into.
        # @return [String]
        # @see #enqueue
        class_attribute :queue_name, default: 'derivative-rodeo'
        # @!endgroup

        ##
        # @return [Aws::SQS::Client]
        #
        # @note
        #
        #   Normaly, I'd like to instantiate the client as part of the initialize method.  However
        #   for the environment in which this runs, we're likely to have the However, in my local
        #   testing, using that approach added 3 seconds to a test.  Hence I'm using a class method
        #   to repurpose the same client.
        def self.client
          @client ||= ::Aws::SQS::Client.new(region: region)
        end

        ##
        # @param client [Aws::SQS::Client]
        def initialize(client: self.class.client)
          @client = client
        end

        ##
        # @return [Aws::SQS::Client]
        attr_reader :client

        ##
        # @return [Hash<Symbol,Object>]
        def to_hash
          super.merge(region: region, queue_name: queue_name)
        end

        ##
        # @api public
        #
        # @param derivative_to_process [Derivatives::Rodeo::Type]
        # @param arena [Derivatives::Rodeo::Arena]
        #
        # @note
        #
        #   Consider that we may have a different queue that we leverage.  In production we've found
        #   that the OCR processing works more efficiently if we batch process them.
        def enqueue(derivative_to_process:, arena:)
          client.send_message(queue_url: queue_url,
                              message_body: arena.to_json(derivative_to_process: derivative_to_process))
        end

        private

        def queue_url
          @queue_url ||= client.get_queue_url(queue_name: queue_name).queue_url
        end
      end
    end
  end
end
