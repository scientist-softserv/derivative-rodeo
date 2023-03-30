# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SpaceStone::Derivatives::Chain do
  # These two derivatives are a known "good derivative" chain.
  let(:derivatives) { [:hocr, :monochrome] }
  subject { described_class.new(derivatives: derivatives) }

  describe "an instance" do
    it { is_expected.to be_a(Enumerable) }
  end

  describe '#to_hash' do
    it 'will have keys that are all symbols' do
      expect(subject.to_hash.keys.all? { |k| k.is_a? Symbol }).to be_truthy
    end
  end

  describe '#each' do
    it 'will yield instances of SpaceStone::Derivatives::Types::BaseType' do
      # NOTE: monochrome yields first, then hocr because hocr depends on monochrome
      expect { |b| subject.each(&b) }.to yield_successive_args(
        SpaceStone::Derivatives::Types::MonochromeType,
        SpaceStone::Derivatives::Types::HocrType
      )
    end
  end
  describe "Sequencer" do
    describe '.call' do
      subject { described_class::Sequencer.call(chain, raise_error: raise_error) }

      let(:raise_error) { false }

      # Creating test table.
      [
        [{}, []],
        [{ peanut: [] }, [:peanut]],
        [{ peanut: [:butter, :jelly], jelly: [:butter], butter: [] }, [:butter, :jelly, :peanut]],
        [{ hocr: [:monochrome, :ketchup], monochrome: [:ketchup], ketchup: [:mustard], mustard: [:hocr] }, []]
      ].each do |chain, expected|
        context "for chain #{chain.inspect}" do
          let(:chain) { chain }

          it { is_expected.to eq(expected) }
        end
      end

      context 'with raise_error: true' do
        it 'raises an Exceptions::TimeToLiveExceededError' do
          expect do
            described_class::Sequencer.call({ hocr: [:hocr] }, raise_error: true)
          end.to raise_exception(SpaceStone::Derivatives::Exceptions::TimeToLiveExceededError)
        end
      end
    end
  end
end
