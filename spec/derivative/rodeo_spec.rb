# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Derivative::Rodeo do
  describe '.config' do
    subject { described_class.config }
    it { is_expected.to be_a described_class::Configuration }

    it "yields a Configuration" do
      expect { |b| described_class.config(&b) }.to yield_with_args(kind_of(described_class::Configuration))
    end
  end

  let(:config) { Fixtures.config }

  describe '.process_derivative' do
    let(:arena) { Fixtures.arena(manifest: manifest) }

    let(:manifest) do
      Fixtures.manifest(
        parent_identifier: parent_identifier,
        original_filename: original_filename,
        derivatives: derivatives,
        mime_type: mime_type,
        path_to_original: path_to_original
      )
    end

    subject { described_class.process_derivative(json: arena.to_json, config: config) }

    context "with a 2 page color PDF" do
      let(:original_filename) { "sample-color-newsletter.pdf" }
      let(:parent_identifier) { "with-original-only" }
      let(:derivatives) { [:split_pdf] }
      let(:mime_type) { "application/pdf" }
      let(:path_to_original) { Fixtures.path_for(original_filename) }

      xit "splits the pages into images and extracts text" do
        subject
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
        subject

        expect(arena.local_storage.exists?(derivative: :original)).to be_truthy
        expect(arena.local_storage.exists?(derivative: :monochrome)).to be_truthy
        expect(arena.local_storage.exists?(derivative: :hocr)).to be_truthy
      end
    end

    context 'with a JPG'
    context 'with a PNG'
    context 'with a MOV'
    context 'with a WAV'
  end

  # ADL: They have Reader PDF, TXT, Thumbnail, Archival PDF
  describe '.process_file_sets_from_csv' do
    let(:csv) do
      CSV.generate do |csv|
        csv << ["parent_identifier", "original_filename", "path_to_original", "monochrome", "mime_type"]
        csv << ["123", "ocr_color.tiff", Fixtures.path_for("ocr_color.tiff"), Fixtures.path_for("ocr_mono.tiff"), nil]
      end
    end

    it "calls and enqueue the entire derivative chain for each provided manifest" do
      described_class.process_file_sets_from_csv(csv, config: config)
    end
  end
end
