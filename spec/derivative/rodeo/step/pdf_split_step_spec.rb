# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Derivative::Rodeo::Step::PdfSplitStep do
  describe 'defaults for' do
    describe '.prerequisites' do
      subject { described_class.prerequisites }

      it { is_expected.to eq([:original]) }
    end

    describe '.spawns' do
      subject { described_class.spawns }

      it { is_expected.to eq([described_class.derived_original_name, :page_ocr]) }
    end

    describe '.pdf_splitter_name' do
      subject { described_class.pdf_splitter_name }

      it { is_expected.to eq :tiff }
    end
  end

  let(:instance) { described_class.new(arena: arena) }
  let(:arena) { Fixtures.arena }

  describe '#pdf_splitter' do
    subject { instance.pdf_splitter }
    it { is_expected.to respond_to(:call) }
  end

  describe '#generate' do
    let(:splitter) { ->(_path_to_pdf) { [__FILE__, __FILE__] } }
    let(:derived_arena) { double(Derivative::Rodeo::Arena, start_processing!: true) }
    subject { instance.generate }

    before { instance.pdf_splitter = splitter }
    it 'will build a derived arena for each page and start processing those arenas' do
      allow(Derivative::Rodeo::Arena).to receive(:for_derived).and_return(derived_arena)
      subject

      expect(derived_arena).to have_received(:start_processing!).exactly(2).times
    end
  end
end
