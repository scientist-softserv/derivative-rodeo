# frozen_string_literal: true

require 'aws-sdk-s3'

module Derivative
  module Rodeo
    module StorageAdapters
      class AwsS3Adapter
        include StorageAdapters::Base

        ##
        # @!group Class Attributes
        #
        # @!attribute [rw]
        # The name of the region in which we're processing.
        # @return [String]
        # @see .client
        # @see Derivative::Rodeo::QueueAdapters::AwsSqsAdapter.region
        class_attribute :region, default: ENV.fetch('AWS_REGION', 'us-east-2'), instance_writer: false

        ##
        # @!attribute [rw]
        # @return [String]
        class_attribute :bucket_name, default: ENV.fetch('AWS_S3_BUCKET', 'derivative_rodeo_bucket')
        # @!endgroup

        def self.resource
          @resource ||= Aws::S3::Resource.new(region: region)
        end

        private

        ##
        # @todo how do we account for a rodeo having a local and remote S3 bucket?
        def bucket
          @bucket ||= self.class.resource.bucket(bucket_name)
        end

        ##
        # This function writes the derivative into the S3 storage, by fetching from the remote URL.
        #
        # @param derivative [Symbol]
        # @param from [StorageAdapters::Base]
        #
        # @return [String] the path to the resource in this storage instance.
        # @raise [Exceptions::DerivativeNotFoundError] when we were not able to successfully fetch
        #        and write the local file.
        # @see #fetch
        def fetch!(derivative:, from:)
          demand_path_for!(derivative: derivative) do |local_path|
            if from.exists?(derivative: derivative)
              remote_path = from.path_to_storage(derivative: derivative)
              # Negotiate writing the remote_path to the bucket's object at the local_path.
              bucket.object(local_path).upload_file(remote_path)
            end
          end
        end

        ##
        # @param derivative [Symbol]
        # @param from [StorageAdapters::Base]
        #
        # @return [String] the path to the resource in this storage instance.
        # @return [FalseClass] when we do not successfully fetch and write the file locally.
        #
        # @see #fetch!
        def fetch(derivative:, from:)
          fetch!(derivative: derivative, from: from)
        rescue Exceptions::DerivativeNotFoundError
          false
        end

        def path(derivative:)
          raise NotImplementedError
        end

        # Check the {#bucket} at for the {#path} of the given :derivative.
        #
        # @param derivative [Symbol, #to_sym]
        #
        # @return [TrueClass] when the file exists in this storage for the given :derivative
        # @return [TrueClass] when the file does not exist in this storage for the given :derivative
        def exists?(derivative:)
          raise NotImplementedError
        end

        ##
        # The logic for writing the file to another system.  We'll need to disentangle that.
        #
        # def write(to:, derivative:)
        #   remote_path = to.path(derivative: derivative)
        #   local_object = bucket.object(path(derivative: derivative))
        #   local_object.download_file(remote_path)
        #   remote_path
        # end
        def download(path)
          file_path = "/tmp/#{path}"
          FileUtils.mkdir_p(File.dirname(file_path))
          obj = bucket.object(path)
          obj.download_file(file_path)
          file_path
        end
      end
    end
  end
end
