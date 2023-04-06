# frozen_string_literal: true

RSpec.describe SpaceStone::Derivatives::Types::HocrType do
  let(:repository) do
    SpaceStone::Derivatives::Repository.new(manifest: manifest,
                                            local_adapter: :file_system,
                                            remote_adapter: :file_system)
  end

  let(:manifest) do
    SpaceStone::Derivatives::Manifest::Original.new(parent_identifier: "123", original_filename: "abc.jpg", derivatives: [:hocr])
  end

  describe ".prerequisites" do
    subject { described_class.prerequisites }
    it { is_expected.to eq([:monochrome]) }
  end

  describe '#generate_for' do
    let(:exception) { SpaceStone::Derivatives::Exceptions::DerivativeNotFoundError.new(derivative: :monochrome, repository: repository) }
    subject { described_class.new.generate_for(repository: repository) }

    before do
      allow(repository).to receive(:demand_local_for!).with(derivative: :hocr).and_call_original
    end

    context "without an existing monochrome derivative" do
      it "will raise an Exceptions::DerivativeNotFoundError exception" do
        expect(repository).to receive(:demand_local_for!)
          .with(derivative: :monochrome)
          .and_raise(exception)
        expect { subject }.to raise_exception(exception.class)
      end
    end

    context 'with an existing monochrome derivative' do
      it 'assign the tesseract derived file to the :hocr derivative for the repository' do
        expect(repository).to receive(:demand_local_for!)
          .with(derivative: :monochrome)
          .and_return(Fixtures.path_for("ocr_mono.tiff"))

        subject
      end
    end
  end
end
