# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Derivative::Rodeo::Utilities::PdfSplitter do
  describe '.for' do
    subject { described_class.for(name) }
    context 'with a known name' do
      let(:name) { :tiff }
      it { is_expected.to eq Derivative::Rodeo::Utilities::PdfSplitter::TiffPage }
    end

    context 'with an unknown name' do
      let(:name) { :biff }
      it { within_block_is_expected.to raise_error NameError }
    end
  end
end
