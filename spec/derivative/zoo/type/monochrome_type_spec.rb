# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Derivative::Zoo::Type::MonochromeType do
  describe ".prerequisites" do
    subject { described_class.prerequisites }
    it { is_expected.to eq([:original]) }
  end

  let(:environment) { Fixtures.pre_processing_environment(manifest: manifest) }

  let(:manifest) do
    Derivative::Zoo::Manifest::Original.new(parent_identifier: "123", original_filename: "abc.jpg", derivatives: [:hocr])
  end

  let(:instance) { described_class.new(environment: environment) }

  describe "#generate_for" do
    subject { instance.generate }
    before do
      allow(environment).to receive(:local_demand!).with(derivative: described_class.to_sym).and_call_original
    end

    context 'with existing :monochrome' do
      let(:image_path) { Fixtures.path_for("ocr_mono.tiff") }

      it "re-uses the file" do
        expect(environment).to receive(:local_demand!)
          .with(derivative: :original)
          .and_return(image_path)

        expect(environment).not_to receive(:local_path)

        # The original monochrome image is in the monochrome slot in the environment.
        expect(subject).not_to eq(image_path)
        # However, the content of each file is identical
        expect(File.read(subject)).to eq(File.read(image_path))
      end
    end

    context 'without existing :monochrome' do
      let(:image_path) { Fixtures.path_for("ocr_color.tiff") }
      it "it converts the existing image" do
        expect(environment).to receive(:local_demand!)
          .with(derivative: :original)
          .and_return(image_path)

        expect(File.read(subject)).not_to eq(File.read(image_path))
      end
    end
  end
end
