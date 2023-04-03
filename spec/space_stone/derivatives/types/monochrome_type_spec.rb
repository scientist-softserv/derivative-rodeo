# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SpaceStone::Derivatives::Types::MonochromeType do
  describe ".prerequisites" do
    subject { described_class.prerequisites }
    it { is_expected.to eq([:image]) }
  end

  let(:repository) do
    SpaceStone::Derivatives::Repository.new(manifest: manifest,
                                            local_adapter: :file_system,
                                            remote_adapter: :file_system)
  end

  let(:manifest) do
    SpaceStone::Derivatives::Manifest.new(parent_identifier: "123", original_filename: "abc.jpg", derivatives: [:hocr])
  end

  describe "#generate_for" do
    subject { described_class.new.generate_for(repository: repository) }
    before do
      allow(repository).to receive(:demand_local_for!).with(derivative: described_class.to_sym, index: 0).and_call_original
    end

    context 'with existing :monochrome' do
      let(:image_path) { Fixtures.path_for("ocr_mono.tiff") }

      it "re-uses the file" do
        expect(repository).to receive(:demand_local_for!)
          .with(derivative: :image)
          .and_return(image_path)

        expect(repository).not_to receive(:local_path)

        # The original monochrome image is in the monochrome slot in the repository.
        expect(subject).not_to eq(image_path)
        # However, the content of each file is identical
        expect(File.read(subject)).to eq(File.read(image_path))
      end
    end

    context 'without existing :monochrome' do
      let(:image_path) { Fixtures.path_for("ocr_color.tiff") }
      it "it converts the existing image" do
        expect(repository).to receive(:demand_local_for!)
          .with(derivative: :image)
          .and_return(image_path)

        expect(File.read(subject)).not_to eq(File.read(image_path))
      end
    end
  end
end
