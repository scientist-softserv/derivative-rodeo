# frozen_string_literal: true

RSpec.describe SpaceStone::Derivatives::Types do
  describe "Base" do
    describe '.to_sym' do
      subject { described_class::BaseType.to_sym }
      it { is_expected.to eq(:base) }
    end

    describe '#to_sym' do
      subject { described_class::BaseType.new.to_sym }
      it { is_expected.to eq(:base) }
    end
  end
end
