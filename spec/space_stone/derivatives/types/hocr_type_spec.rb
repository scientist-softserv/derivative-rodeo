# frozen_string_literal: true

RSpec.describe SpaceStone::Derivatives::Types::HocrType do
  let(:repository) { SpaceStone::Derivatives::Repository.new(identifier: manifest.identifier) }
  let(:manifest) do
    SpaceStone::Derivatives::Manifest.new(parent_identifier: "123", original_filename: "abc.jpg", derivatives: [:hocr])
  end

  describe ".prerequisites" do
    subject { described_class.prerequisites }
    it { is_expected.to eq([:monochrome]) }
  end

  describe '#pre_process!' do
    subject { described_class.new.pre_process!(repository: repository) }

    before do
      allow(repository).to receive(:local_path_for).with(derivative: described_class.to_sym).and_return(existing_hocr_path)
    end

    context 'with existing :hocr' do
      let(:existing_hocr_path) { "path/to/hocr" }
      it "returns the existing :hocr" do
        expect(subject).to eq(existing_hocr_path)
      end
    end

    context 'without an existing :hocr' do
      let(:existing_hocr_path) { nil }

      it 'will create a new derivative from the existing :monochrome file' do
        allow(repository).to receive(:local_path_for!)
          .with(derivative: :monochrome)
          .and_return(Fixtures.path_for('ocr_mono.tiff'))
        expect(repository).to receive(:put).with(derivative: described_class.to_sym, path: kind_of(String))

        # TODO: add check that the file was created locally.
        subject
      end
    end
  end
end
