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

    describe '.path_to_page_splitting_service' do
      subject { described_class.path_to_page_splitting_service }

      it { is_expected.to be_nil }
    end
  end

  let(:instance) { described_class.new(arena: arena) }

  describe '#generate' do
    let(:arena) { Fixtures.arena }
    let(:splitter) { ->(_path_to_pdf) { [__FILE__, __FILE__] } }
    let(:derived_arena) { double(Derivative::Rodeo::Arena, start_processing!: true) }
    subject { instance.generate }

    before { instance.path_to_page_splitting_service = splitter }
    it 'will build a derived arena for each page and start processing those arenas' do
      allow(Derivative::Rodeo::Arena).to receive(:for_derived).and_return(derived_arena)
      subject

      expect(derived_arena).to have_received(:start_processing!).exactly(2).times
    end
  end
end
