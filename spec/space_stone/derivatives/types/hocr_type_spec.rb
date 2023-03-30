# frozen_string_literal: true

RSpec.describe SpaceStone::Derivatives::Types::HocrType do
  let(:repository) { double(put: true) }
  let(:manifest) do
    SpaceStone::Derivatives::Manifest.new(parent_identifier: "123", original_filename: "abc.jpg", derivatives: [:hocr])
  end

  describe '#pre_process!' do
    subject { described_class.new.pre_process!(repository: repository, manifest: manifest, tmpdir: tmpdir) }
    let(:tmpdir) { Dir.mktmpdir }

    before do
      allow(repository).to receive(:local_path_for)
        .with(identifier: manifest.identifier, derivative: described_class.to_sym)
        .and_return(existing_hocr_path)
    end
    context 'with existing :hocr' do
      let(:existing_hocr_path) { "path/to/hocr" }
      it "does not create a new derivative" do
        expect(subject).to eq(existing_hocr_path)
      end
    end

    context 'without an existing :hocr' do
      let(:existing_hocr_path) { nil }

      it 'will create a new derivative from the existing :monochrome file' do
        allow(repository).to receive(:local_path_for!)
          .with(identifier: manifest.identifier, derivative: :monochrome)
          .and_return(Fixtures.path_for('ocr_mono.tiff'))

        subject

        expect(repository).to have_received(:put)
          .with(
                                  identifier: manifest.identifier,
                                  derivative: described_class.to_sym,
                                  path: kind_of(String)
                                )
      end
    end
  end
end
