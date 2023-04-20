# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Derivative::Rodeo::Invocation::ProcessFileSetsFromCsvInvocation do
  context "Invocation::Base interface" do
    subject { described_class }
    it { is_expected.to respond_to(:call) }
  end

  let(:config) { Fixtures.config }
  let(:instance) { described_class.new(config: config, body: csv) }

  describe '.convert_to_manifest' do
    let(:row) do
      {
        work_identifier: "123",
        file_set_filename: "ocr_color.tiff",
        path_to_original: Fixtures.path_for("ocr_color.tiff"),
        monochrome: Fixtures.path_for("ocr_mono.tiff"),
        hocr: Fixtures.path_for("ocr_mono_text_hocr.html")
      }
    end
    subject { described_class.convert_to_manifest(row: row) }
    it { is_expected.to be_a(Derivative::Rodeo::Manifest::PreProcess) }

    it "has derivatives array based on additional provided columns" do
      expect(subject.derivatives).to eq(hocr: row.fetch(:hocr), monochrome: row.fetch(:monochrome))
    end
  end

  describe '#call' do
    subject { instance.call }
    let(:csv) do
      CSV.generate do |csv|
        csv << ["work_identifier", "file_set_filename", "path_to_original", "monochrome", "mime_type"]
        csv << ["123", "ocr_color.tiff", Fixtures.path_for("ocr_color.tiff"), Fixtures.path_for("ocr_mono.tiff"), nil]
        csv << ["456", "ocr_color.tiff", Fixtures.path_for("ocr_color.tiff"), Fixtures.path_for("ocr_mono.tiff"), "image/tiff"]
      end
    end

    it "enqueues for processing the provided record(s)" do
      expect(instance.queue).to(
        receive(:enqueue)
          .with(arena: kind_of(Derivative::Rodeo::Arena), derivative_to_process: :base_file_for_chain)
          .exactly(2).times
      )
      subject
    end
  end
end
