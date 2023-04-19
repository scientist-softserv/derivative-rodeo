# frozen_string_literal: true
module Fixtures
  def self.aws_s3_bucket
    AwsS3FauxBucket.new
  end

  def self.manifest(
    parent_identifier: 'parent-identifier',
    original_filename: 'ocr_color.tiff',
    derivatives: {
      monochrome: Fixtures.path_for('ocr_gray.tiff')
    },
    mime_type: "image/tiff",
    path_to_original: Fixtures.path_for("ocr_color.tiff")
  )

    Derivative::Rodeo::Manifest::PreProcess.new(
      parent_identifier: parent_identifier,
      original_filename: original_filename,
      derivatives: derivatives,
      mime_type: mime_type,
      path_to_original: path_to_original
    )
  end

  def self.config
    Derivative::Rodeo::Configuration.new do |cfg|
      cfg.local_storage = :file_system
      cfg.remote_storage = :from_manifest
      cfg.queue = :inline
      yield(cfg) if block_given?
    end
  end

  def self.arena(manifest: Fixtures.manifest, config: Fixtures.config)
    Derivative::Rodeo::Arena.for_pre_processing(manifest: manifest, config: config)
  end

  def self.path_for(name)
    File.join(File.expand_path("fixtures/files/#{name}", __dir__))
  end

  def self.tmp_subdir_of(*name)
    parent_dir = Dir.mktmpdir

    FileUtils.mkdir_p(File.join(parent_dir, *name)).first
  end

  ##
  # This class is very rudimentary implementation of a bucket.  It conforms to the necessary
  # interface for downloading and uploading.
  #
  # @see [Derivative::Rodeo::StorageAdapters::AwsS3Adapter]
  class AwsS3FauxBucket
    def initialize
      @storage = {}
    end
    attr_reader :storage
    def object(path)
      # Yup, we've got nested buckets
      @storage[path] ||= Storage.new
    end

    def objects(prefix:)
      @storage.select do |path, _file|
        path.start_with?(prefix)
      end
    end

    class Storage
      def initialize
        @storage = {}
      end
      attr_reader :storage

      def upload_file(path)
        @storage[:upload] = path
      end

      def download_file(path)
        return false unless @storage.key?(:upload)
        storage_path = @storage.fetch(:upload)

        File.open(path, 'wb') do |f|
          if File.file?(storage_path)
            f.puts File.read(storage_path)
          else
            f.puts Derivative::Rodeo::Utilities::Url.read(storage_path)
          end
        end
      end
    end
  end
end
