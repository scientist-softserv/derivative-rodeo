# frozen_string_literal: true

RSpec.describe SpaceStone::Derivatives::Types::HocrType do
  let(:environment) do
    SpaceStone::Derivatives::Environment.for_original(manifest: manifest,
                                                      local: :file_system,
                                                      remote: :file_system,
                                                      queue: :inline)
  end

  let(:manifest) do
    SpaceStone::Derivatives::Manifest::Original.new(parent_identifier: "123", original_filename: "abc.jpg", derivatives: [:hocr])
  end

  describe ".prerequisites" do
    subject { described_class.prerequisites }
    it { is_expected.to eq([:monochrome]) }
  end

  describe '#generate_for' do
    let(:exception) { SpaceStone::Derivatives::Exceptions::DerivativeNotFoundError.new(derivative: :monochrome, storage: :file_system) }
    subject { described_class.new.generate_for(environment: environment) }

    before do
      allow(environment).to receive(:local_demand!).with(derivative: :hocr).and_call_original
    end

    context "without an existing monochrome derivative" do
      it "will raise an Exceptions::DerivativeNotFoundError exception" do
        expect(environment).to receive(:local_demand!)
          .with(derivative: :monochrome)
          .and_raise(exception)
        expect { subject }.to raise_exception(exception.class)
      end
    end

    context 'with an existing monochrome derivative' do
      it 'assign the tesseract derived file to the :hocr derivative for the environment' do
        expect(environment).to receive(:local_demand!)
          .with(derivative: :monochrome)
          .and_return(Fixtures.path_for("ocr_mono.tiff"))

        subject
      end
    end
  end
end
