# frozen_string_literal: true
module Fixtures
  # rubocop:disable Metrics/ParameterLists
  def self.message(chain: [], derivative: :original, manifest: pre_processing_manifest, local_storage: :file_system, remote_storage: :from_manifest, queue: :inline, config: pre_processing_config)
    chain = Derivative::Rodeo::Chain.for_pre_processing(config: config)
    Derivative::Rodeo::Message.new(
      manifest: manifest,
      derivative: derivative,
      local_storage: local_storage,
      remote_storage: remote_storage,
      queue: queue,
      chain: chain
    )
  end
  # rubocop:enable Metrics/ParameterLists

  def self.pre_processing_manifest(
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

  def self.pre_processing_config
    Derivative::Rodeo::Configuration.new do |cfg|
      cfg.local_storage = :file_system
      cfg.remote_storage = :from_manifest
      cfg.queue = :inline
      yield(cfg) if block_given?
    end
  end

  def self.pre_processing_arena(manifest: Fixtures.pre_processing_manifest, config: pre_processing_config)
    Derivative::Rodeo::Arena.for_pre_processing(manifest: manifest, config: config)
  end

  def self.path_for(name)
    File.join(File.expand_path("fixtures/files/#{name}", __dir__))
  end

  def self.tmp_subdir_of(*name)
    parent_dir = Dir.mktmpdir

    FileUtils.mkdir_p(File.join(parent_dir, *name)).first
  end
end
