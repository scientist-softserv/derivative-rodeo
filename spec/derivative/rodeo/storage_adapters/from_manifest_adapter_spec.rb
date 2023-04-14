# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Derivative::Rodeo::StorageAdapters::FromManifestAdapter do
  let(:manifest) { Fixtures.manifest(path_to_original: __FILE__) }
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

  describe '#exists?' do
    let(:manifest) { Fixtures.manifest(derivatives: { derivative => path }) }
    let(:path) { __FILE__ }

    subject { instance.exists?(derivative: derivative) }

    context 'when the derivative exists as a file' do
      it { is_expected.to be_truthy }
    end

    context 'when the derivative is a remote URL' do
      context 'and the URL returns a 200 status' do
        xit { is_expected.to be_truthy }
      end
      context 'and the URL is non-200 status' do
        xit { is_expected.to be_falsey }
      end
    end
  end

  describe '#read' do
    context 'when the derivative path is a local file' do
      it 'returns the content' do
        expect(instance.read(derivative: :original)).to eq(File.read(__FILE__))
      end
    end

    context 'when the derivative path is a URL' do
      xit "will return the file's content"
    end
  end

  describe "#write" do
    subject { instance.write(derivative: :nope) }

    it { within_block_is_expected.to raise_error(Derivative::Rodeo::Exceptions::InvalidFunctionForStorageAdapterError) }
  end
end
