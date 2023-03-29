# frozen_string_literal: true
require 'active_support/core_ext/string/inflections'

RSpec.describe SpaceStone::Derivatives::Utilities::DerivativeChainValidator do
  describe '.call' do
    subject { described_class.call(chain: chain, raise_error: raise_error) }

    # Creating test table.
    [
      [{}, true],
      [{ hocr: [:hocr] }, false],
      [{ monochrome: [] }, true],
      [{ monochrome: [:hocr], hocr: [:monochrome] }, false],
      [{ hocr: [:monochrome, :ketchup], monochrome: [:ketchup], ketchup: [:mustard], mustard: [:hocr] }, false],
      [{ hocr: [:monochrome, :ketchup], monochrome: [:ketchup], ketchup: [:mustard], mustard: [:pickles] }, true]
    ].each do |chain, expected|
      let(:raise_error) { false }
      context "for chain #{chain.inspect}" do
        let(:chain) { chain }

        it { is_expected.to eq(expected) }
      end
    end

    context 'with raise_error: true' do
      it 'raises an Exceptions::TimeToLiveExceededError' do
        expect do
          described_class.call(chain: { hocr: [:hocr] }, raise_error: true)
        end.to raise_exception(SpaceStone::Derivatives::Exceptions::TimeToLiveExceededError)
      end
    end
  end
end
