# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Derivative::Rodeo::StorageAdapters::FromManifestAdapter do
  let(:manifest) { Fixtures.pre_processing_manifest(path_to_original: __FILE__) }
  let(:derivative) { :hello }
  subject(:instance) { described_class.new(manifest: manifest) }

  it { is_expected.to delegate_method(:path_to).to(:manifest) }

  describe "#assign!" do
    subject { instance.assign!(derivative: derivative) }

    it { within_block_is_expected.to raise_error(Derivative::Rodeo::Exceptions::InvalidFunctionForStorageAdapterError) }
  end

  describe '#demand!' do
    subject { instance.demand!(derivative: derivative) }

    context 'when the local does not exist' do
      it { within_block_is_expected.to raise_error(Derivative::Rodeo::Exceptions::DerivativeNotFoundError) }
    end
  end

  describe '#read' do
    context 'when the derivative path is a local file' do
      it 'returns the content' do
        expect(instance.read(derivative: :original)).to eq(File.read(__FILE__))
      end
    end

    context 'when the derivative path is a URL' do
      xit 'returns the content'
      xit 'pulls the content'
    end
  end

  describe "#write" do
    subject { instance.write(derivative: :nope) }

    it { within_block_is_expected.to raise_error(Derivative::Rodeo::Exceptions::InvalidFunctionForStorageAdapterError) }
  end
end
