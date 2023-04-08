# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SpaceStone::Derivatives::Chain do
  describe '.from_mime_types_for' do
    let(:manifest) { Fixtures.pre_processing_manifest(mime_type: 'application/pdf') }
    subject { described_class.from_mime_types_for(manifest: manifest) }

    it { is_expected.to respond_to(:to_hash) }
    it { is_expected.to be_a(Enumerable) }
  end

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
    it 'will yield instances of SpaceStone::Derivatives::Type::BaseType' do
      # NOTE: image yields first, then monochrome which depends on image, then hocr which depends on
      # image
      expect { |b| subject.each(&b) }.to yield_successive_args(
                                           SpaceStone::Derivatives::Type::OriginalType,
                                           SpaceStone::Derivatives::Type::MonochromeType,
                                           SpaceStone::Derivatives::Type::HocrType
                                         )
    end
  end

  describe '#find_index' do
    subject { described_class.new(derivatives: derivatives).find_index(derivative) }

    context 'when the derivative exists' do
      let(:derivative) { SpaceStone::Derivatives::Type::MonochromeType }
      it { is_expected.to be_a(Integer) }
    end

    context 'when the derivative does not exist' do
      let(:derivative) { SpaceStone::Derivatives::Types }
      it { is_expected.to be_nil }
    end
  end

  describe "Sequencer" do
    describe '.call' do
      subject { described_class::Sequencer.call(chain, raise_error: false) }

      # Creating test table.
      [
        [{}, []],
        [{ peanut: [] }, [:peanut]],
        [{ a: [:b, :c, :d], b: [:e], c: [:d], e: [:c, :f], d: [:f], f: [] }, [:f, :d, :c, :e, :b, :a]],
        [{ peanut: [:butter, :jelly], jelly: [:butter], butter: [] }, [:butter, :jelly, :peanut]],
        # Circular dependencies have no chain; see the :raise_error directive
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
