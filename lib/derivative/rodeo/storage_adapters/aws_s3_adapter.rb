# frozen_string_literal: true

require 'aws-sdk-s3'
require 'fileutils'

module Derivative
  module Rodeo
    module StorageAdapters
      ##
      # A {StorageAdapters::Base} that leverages AWS's S3 storage system.
      #
      # @see https://github.com/scientist-softserv/derivative-rodeo/issues/2 Acceptance Criteria
      class AwsS3Adapter
        include StorageAdapters::Base

        ##
        # @param manifest [Derivative::Rodeo::Bucket, Hash]
        # @param bucket [Aws::S3::Bucket]
        def initialize(manifest:, bucket: default_bucket)
          super(manifest: manifest)
          @bucket = bucket
          # We rely on super method to coerce given manifest into an act
          @directory_name = File.join(*self.manifest.directory_slugs)
        end

        attr_reader :bucket

        ##
        # @return [String]
        attr_reader :directory_name
        private :directory_name

        ##
        # @!group Class Attributes
        #
        # @!attribute [rw]
        # The name of the region in which we're processing.
        # @return [String]
        # @see .client
        # @see Derivative::Rodeo::QueueAdapters::AwsSqsAdapter.region
        class_attribute :region, default: ENV.fetch('AWS_REGION_NAME', 'us-east-2'), instance_writer: false

        ##
        # @!attribute [rw]
        # @return [String]
        class_attribute :bucket_name, default: ENV.fetch('AWS_S3_BUCKET_NAME', 'derivative-rodeo-bucket')
        # @!endgroup

        ##
        # @return [Aws::S3::Resource]
        def self.resource
          @resource ||= Aws::S3::Resource.new(region: region)
        end

        ##
        # We need a bucket to interact with.
        # @see Fixtures.aws_s3_bucket
        def default_bucket
          self.class.resource.bucket(bucket_name)
        end
        private :default_bucket

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
          demand_path_for!(derivative: derivative) do |local_storage_path|
            if from.exists?(derivative: derivative)
              remote_path = from.path_to_storage(derivative: derivative)
              # Negotiate writing the remote_path to the bucket's object at the local_storage_path.
              bucket.object(local_storage_path).upload_file(remote_path)
            end
          end
        end

        def path_to_storage(derivative:)
          # TODO: Should there be a leading "/"?  See spec for current behavior.
          File.join(directory_name, derivative.to_sym.to_s)
        end
        alias path path_to_storage

        ##
        # Check the {#bucket} at for the {#path} of the given :derivative.
        #
        # @param derivative [Symbol, #to_sym]
        #
        # @return [TrueClass] when the file exists in this storage for the given :derivative
        # @return [FalseClass] when the file does not exist in this storage for the given :derivative
        def exists?(derivative:)
          path = path_to_storage(derivative: derivative)
          bucket.objects(prefix: path).count.positive?
        end

        ##
        # @api public
        #
        # @param derivative [Symbol]
        # @param root [String] the root directory where we'll download the derivative from the
        #        bucket.
        # @param perform_download [Boolean] a helper parameter for cleaning up tests.  Also
        #        alludes to the fact that this method violates the command/query separation.
        #
        # @return [String] The path to a version of the :derivative on which file system processes
        #         can operate.
        #
        # @raise [Exceptions::FileNotFoundForShellProcessing] When we're unable to download the
        #        given file.
        #
        # @note
        #
        # This changes the file system state.  It is confusing in that we're moving a file from an
        # S3 bucket to a local file system for processing.
        #
        # @see https://github.com/scientist-softserv/space_stone/blob/c433a4e38b9acac335abaa18daa33dcf0d22aeb4/lib/space_stone/s3_service.rb#L21-L27
        def path_for_shell_commands(derivative:, root: Dir.mktmpdir, perform_download: true)
          target_processing_path = File.join(root, path_to_storage(derivative: derivative))

          return target_processing_path if File.file?(target_processing_path)

          if perform_download
            # Ensure that we have this file
            FileUtils.mkdir_p(File.dirname(target_processing_path))

            s3_object = bucket.object(path_to_storage(derivative: derivative))

            s3_object.download_file(target_processing_path)
          end

          raise Exceptions::FileNotFoundForShellProcessing.new(path: target_processing_path, adapter: self) unless File.file?(target_processing_path)
          target_processing_path
        end
      end
    end
  end
end
