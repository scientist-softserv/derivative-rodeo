# frozen_string_literal: true

require 'spec_helper'

RSpec.describe "Features" do
  let(:manifest) { Fixtures.pre_processing_manifest }
  context "with a 2 page color PDF" do
    let(:basename) { "sample-color-newsletter.pdf" }
    let(:parent_identifier) { "with-original-only" }
    let(:derivatives) { [:split_pdf] }

    xit "splits the pages into images and extracts text" do
      environment.process_start!
    end
  end

  context "with a color image" do
    let(:derivatives) { [:hocr] }
    let(:parent_identifier) { "with-original-only" }
    let(:basename) { "ocr_color.tiff" }

    it "runs the pre-processing" do
      environment = SpaceStone::Derivatives::Environment.for_pre_processing(manifest: manifest)
      environment.process_start!

      expect(environment.local_exists?(derivative: :original)).to be_truthy
      expect(environment.local_exists?(derivative: :monochrome)).to be_truthy
      expect(environment.local_exists?(derivative: :hocr)).to be_truthy
    end
  end
end
