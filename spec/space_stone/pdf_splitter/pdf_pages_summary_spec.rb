# frozen_string_literal: true
RSpec.describe SpaceStone::PdfSplitter::PdfPagesSummary do
  describe '.extract' do
    before do
      allow(described_class::Extractor).to receive(:call).with(__FILE__).and_return(:default_extractor!)
    end

    it 'delegates to the given extractor' do
      extractor = ->(_path) { :given_extractor! }
      expect(described_class.extract(path: __FILE__, extractor: extractor)).to eq(:given_extractor!)
    end

    it 'uses the default extractor for extraction' do
      expect(described_class.extract(path: __FILE__)).to eq(:default_extractor!)
    end
  end

  subject do
    described_class.new(path: __FILE__, page_count: 1, width: 2, height: 3,
                        pixels_per_inch: 4, color_description: 'rgb', channels: 5,
                        bits_per_channel: 6)
  end

  it { is_expected.to respond_to(:valid?) }
  it { is_expected.to respond_to(:path) }
  it { is_expected.to respond_to(:page_count) }
  it { is_expected.to respond_to(:width) }
  it { is_expected.to respond_to(:height) }
  it { is_expected.to respond_to(:pixels_per_inch) }
  it { is_expected.to respond_to(:ppi) }
  it { is_expected.to respond_to(:color) }
  it { is_expected.to respond_to(:color_description) }
  it { is_expected.to respond_to(:channels) }
  it { is_expected.to respond_to(:bits) }
  it { is_expected.to respond_to(:bits_per_channel) }
end
