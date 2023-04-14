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

        # @!attribute [rw]
        # @return [String]
        class_attribute :bucket_name, default: ENV.fetch('AWS_S3_BUCKET', 'derivative_rodeo_bucket')
        # @!endgroup

        def self.resource
          @resource ||= Aws::S3::Resource.new(region: region)
        end

        ##
        # @todo how do we account for a rodeo having a local and remote S3 bucket?
        def bucket
          @bucket ||= self.class.resource.bucket(bucket_name)
        end

        def upload(path)
          obj = bucket.object(path.sub('/tmp/', ''))
          obj.upload_file(path)
        end

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
