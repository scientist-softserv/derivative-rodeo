# frozen_string_literal: true

RSpec.describe SpaceStone::Derivatives::Types do
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

    it { is_expected.to respond_to :pre_process! }
  end
end
