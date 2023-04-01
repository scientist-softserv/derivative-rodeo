# frozen_string_literal: true

RSpec.describe SpaceStone::Derivatives::Types::HocrType do
  let(:repository) { double(SpaceStone::Derivatives::Repository, demand_local_for!: false) }
  let(:manifest) do
    SpaceStone::Derivatives::Manifest.new(parent_identifier: "123", original_filename: "abc.jpg", derivatives: [:hocr])
  end

  describe ".prerequisites" do
    subject { described_class.prerequisites }
    it { is_expected.to eq([:monochrome]) }
  end

  describe '#generate_for' do
    let(:exception) { SpaceStone::Derivatives::Exceptions::DerivativeNotFoundError.new(derivative: :monochrome, repository: repository) }
    subject { described_class.new.generate_for(repository: repository) }

    context "without an existing monochrome derivative" do
      it "will raise a Exceptions::DerivativeNotFoundError exception" do
        expect(repository).to receive(:demand_local_for!)
          .with(derivative: :monochrome)
          .and_raise(exception)
        expect { subject }.to raise_exception(exception.class)
      end
    end

    context 'with an existing monochrome derivative' do
      xit 'assign the tesseract derived file to the :hocr derivative for the repository' do
      end
    end
  end
end
