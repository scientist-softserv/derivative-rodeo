# frozen_string_literal: true
module Fixtures
  def self.pre_processing_manifest(
    parent_identifier: 'parent-identifier',
    original_filename: 'ocr_color.tiff',
    derivatives: {
      monochrome: Fixtures.path_for('ocr_gray.tiff')
    },
    mime_type: "image/tiff",
    path_to_original: Fixtures.path_for("ocr_color.tiff")
  )

    SpaceStone::Derivatives::Manifest::PreProcess.new(
      parent_identifier: parent_identifier,
      original_filename: original_filename,
      derivatives: derivatives,
      mime_type: mime_type,
      path_to_original: path_to_original
    )
  end

  def self.pre_processing_environment(manifest: Fixtures.pre_processing_manifest, config: nil)
    config ||= SpaceStone::Derivatives::Configuration.new do |cfg|
      cfg.local_storage = :file_system
      cfg.remote_storage = :from_manifest
      cfg.queue = :inline
    end
    SpaceStone::Derivatives::Environment.for_pre_processing(manifest: manifest, config: config)
  end

  def self.path_for(name)
    File.join(File.expand_path("fixtures/files/#{name}", __dir__))
  end

  def self.tmp_subdir_of(*name)
    parent_dir = Dir.mktmpdir

    FileUtils.mkdir_p(File.join(parent_dir, *name)).first
  end
end
