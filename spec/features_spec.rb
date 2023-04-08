# frozen_string_literal: true

require 'spec_helper'

RSpec.describe "Features" do
  let(:manifest) do
    Fixtures.pre_processing_manifest(
    parent_identifier: parent_identifier,
    original_filename: original_filename,
    derivatives: derivatives,
    mime_type: mime_type,
    path_to_original: path_to_original
  )
  end

  let(:environment) { Fixtures.pre_processing_environment(manifest: manifest) }
  context "with a 2 page color PDF" do
    let(:original_filename) { "sample-color-newsletter.pdf" }
    let(:parent_identifier) { "with-original-only" }
    let(:derivatives) { [:split_pdf] }
    let(:mime_type) { "application/pdf" }
    let(:path_to_original) { Fixtures.path_for(original_filename) }

    xit "splits the pages into images and extracts text" do
      environment.start_processing!
    end
  end

  context "with a color image" do
    # Yes these are the defaults, but I'd rather be explicit in what we're doing.
    let(:parent_identifier) { 'parent-identifier' }
    let(:original_filename) { 'ocr_color.tiff' }
    let(:derivatives) { { monochrome: Fixtures.path_for('ocr_gray.tiff') } }
    let(:mime_type) { "image/tiff" }
    let(:path_to_original) { Fixtures.path_for(original_filename) }

    it "runs the pre-processing and mime type processing" do
      environment.start_processing!

      expect(environment.local_exists?(derivative: :original)).to be_truthy
      expect(environment.local_exists?(derivative: :monochrome)).to be_truthy
      expect(environment.local_exists?(derivative: :hocr)).to be_truthy
    end
  end
end
