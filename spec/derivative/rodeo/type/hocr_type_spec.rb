# frozen_string_literal: true

RSpec.describe Derivative::Rodeo::Type::HocrType do
  let(:arena) { Fixtures.pre_processing_arena(manifest: manifest) }

  let(:manifest) do
    Derivative::Rodeo::Manifest::Original.new(parent_identifier: "123", original_filename: "abc.jpg", derivatives: [:hocr])
  end

  let(:instance) { described_class.new(arena: arena) }

  describe ".prerequisites" do
    subject { described_class.prerequisites }
    it { is_expected.to eq([:monochrome]) }
  end

  describe '#generate_for' do
    let(:exception) { Derivative::Rodeo::Exceptions::DerivativeNotFoundError.new(derivative: :monochrome, storage: :file_system) }
    subject { instance.generate }

    before do
      allow(arena).to receive(:local_demand!).with(derivative: :hocr).and_call_original
    end

    context "without an existing monochrome derivative" do
      it "will raise an Exceptions::DerivativeNotFoundError exception" do
        expect(arena).to receive(:local_demand!)
          .with(derivative: :monochrome)
          .and_raise(exception)
        expect { subject }.to raise_exception(exception.class)
      end
    end

    context 'with an existing monochrome derivative' do
      it 'assign the tesseract derived file to the :hocr derivative for the arena' do
        expect(arena).to receive(:local_demand!)
          .with(derivative: :monochrome)
          .and_return(Fixtures.path_for("ocr_mono.tiff"))

        subject
      end
    end
  end
end
