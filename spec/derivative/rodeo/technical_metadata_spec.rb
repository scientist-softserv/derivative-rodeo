# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Derivative::Rodeo::TechnicalMetadata do
  let(:struct) do
    described_class.new(color: 1, num_components: 2, bits_per_component: 3, width: 4, height: 5, content_type: 'image/jp2')
  end

  subject { struct }

  it { is_expected.to respond_to :color }
  it { is_expected.to respond_to :num_components }
  it { is_expected.to respond_to :number_of_components }
  it { is_expected.to respond_to :bits_per_component }
  it { is_expected.to respond_to :width }
  it { is_expected.to respond_to :height }
  it { is_expected.to respond_to :content_type }
  it { is_expected.to respond_to :monochrome? }

  context '#to_hash' do
    subject { struct.to_hash }

    it { is_expected.to have_key(:color) }
    it { is_expected.to have_key(:num_components) }
    it { is_expected.to have_key(:bits_per_component) }
    it { is_expected.to have_key(:width) }
    it { is_expected.to have_key(:height) }
    it { is_expected.to have_key(:content_type) }
  end
end
