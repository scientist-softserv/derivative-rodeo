# frozen_string_literal: true

require 'aws-sdk-sqs'

module Derivative
  module Rodeo
    module QueueAdapters
      ##
      # An adapter for leveraging Amazon Web Services Simple Queue Service
      #
      # @see https://github.com/scientist-softserv/space_stone/blob/c433a4e38b9acac335abaa18daa33dcf0d22aeb4/lib/space_stone/sqs_service.rb
      # @see https://rubygems.org/gems/aws-sdk-sqs
      class AwsSqsAdapter
        include QueueAdapters::Base

        class_attribute :region, default: 'us-east-2', instance_writer: false
        class_attribute :queue_name, default: 'derivative-rodeo'

        # @return [Aws::SQS::Client]
        # @note Normaly, I'd like to instantiate the client as part of the initialize method.
        #       However for the environment in which this runs, we're likely to have the However, in
        #       my local testing, using that approach added 3 seconds to a test.  Hence I'm using a
        #       class method to repurpose the same client.
        def self.client
          @client ||= ::Aws::SQS::Client.new(region: region)
        end

        # @param [Aws::SQS::Client]
        def initialize(client: self.class.client)
          @client = client
        end

        # @return [Hash<Symbol,Object>]
        def to_hash
          super.merge(region: region, queue_name: queue_name)
        end

        ##
        # @api public
        #
        # @param derivative [Derivatives::Rodeo::Type]
        # @param arena [Derivatives::Rodeo::Arena]
        #
        # @note Consider that we may have a different queue that we leverage.  In production we've
        #       found that the OCR processing works more efficiently if we batch process them.
        def enqueue(derivative:, arena:)
          message = message_for(derivative: derivative, arena: arena)
          client.send_message(queue_url: queue_url,
                              message_body: message.to_json)
        end

        ##
        # @api private
        #
        # @param derivative [Derivatives::Rodeo::Type]
        # @param arena [Derivatives::Rodeo::Arena]
        #
        # @return [Hash, #to_json]
        def message_for(derivative:, arena:)
          {
            # We need to know what derivative we're enqueuing.
            derivative: derivative.to_sym,
            # We need to know the manifest's information, as there are clues to where we run that.
            manifest: arena.manifest.to_hash,
            # We need to know the name of the queue we're using.  Why not the #to_hash method?
            # Because later processes might say "I want to use the SQS queue
            queue: to_sym
          }
        end

        private

        def queue_url
          client.get_queue_url(queue_name: queue_name).queue_url
        end
      end
    end
  end
end
