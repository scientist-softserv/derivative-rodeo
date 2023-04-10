# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Derivative::Rodeo::StorageAdapters::FromManifestAdapter do
  let(:manifest) { Fixtures.pre_processing_manifest(path_to_original: __FILE__) }
  subject(:instance) { described_class.new(manifest: manifest) }

  it { is_expected.to delegate_method(:path_to).to(:manifest) }

  describe '#read' do
    it 'returns the content' do
      expect(instance.read(derivative: :original)).to eq(File.read(__FILE__))
    end
  end

  describe '#assign!' do
    subject { instance.assign! }

    it { within_block_is_expected.to raise_error(Derivative::Rodeo::Exceptions::InvalidFunctionForStorageAdapterError) }
  end
end
