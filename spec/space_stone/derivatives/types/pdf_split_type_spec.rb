# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SpaceStone::Derivatives::Types::PdfSplitType do
  describe 'defaults for' do
    describe '.prerequisites' do
      subject { described_class.prerequisites }

      it { is_expected.to eq([:original]) }
    end

    describe '.derivative_types_for_split' do
      subject { described_class.derivative_types_for_split }

      it { is_expected.to eq([:ocr]) }
    end

    describe '.page_splitting_service' do
      subject { described_class.page_splitting_service }

      it { is_expected.to be_nil }
    end
  end

  describe '#generate_for' do
    it "needs specs"
  end
end
