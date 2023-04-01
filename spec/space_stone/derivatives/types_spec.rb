# frozen_string_literal: true

RSpec.describe SpaceStone::Derivatives::Types do
  describe '.for' do
    subject { described_class.for(type) }
    {
      hocr: SpaceStone::Derivatives::Types::HocrType,
      monochrome: SpaceStone::Derivatives::Types::MonochromeType
    }.each do |type, expected|
      context type.inspect.to_s do
        let(:type) { type }
        it { is_expected.to eq(expected) }
      end
    end

    context "for un-registered type" do
      it "is expected to raise an error" do
        expect { described_class.for(:obviously_missing) }.to raise_exception(NameError)
      end
    end
  end
  describe "BaseType" do
    describe '.to_sym' do
      subject { described_class::BaseType.to_sym }
      it { is_expected.to eq(:base) }
    end

    let(:instance) { described_class::BaseType.new }
    subject { instance }

    describe '#to_sym' do
      subject { instance.to_sym }
      it { is_expected.to eq(:base) }
    end

    it { is_expected.to respond_to :generate_for }
  end
end
