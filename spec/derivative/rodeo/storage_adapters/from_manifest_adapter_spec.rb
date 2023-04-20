# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Derivative::Rodeo::StorageAdapters::FromManifestAdapter do
  let(:manifest) { Fixtures.manifest(path_to_original: __FILE__) }
  let(:derivative) { :hello }
  subject(:instance) { described_class.new(manifest: manifest) }

  it { is_expected.to delegate_method(:path_to).to(:manifest) }
  it { is_expected.to respond_to(:path_to_storage) }

  # shared examples for #path_to_storage, #demand_path_for!

  describe '#exists?' do
    let(:manifest) { Fixtures.manifest(derivatives: { derivative => path }) }
    let(:path) { __FILE__ }

    subject { instance.exists?(derivative: derivative) }

    context 'when the derivative exists as a file' do
      it { is_expected.to be_truthy }
    end

    context 'when the derivative is a remote URL' do
      let(:path) { "https://takeonrules.com/" }

      context 'and the URL does not exist' do
        before { allow(Derivative::Rodeo::Utilities::Url).to receive(:exists?).with(path).and_return(true) }
        it { is_expected.to be_truthy }
      end
      context 'when the URL does not exist' do
        before { allow(Derivative::Rodeo::Utilities::Url).to receive(:exists?).with(path).and_return(false) }
        it { is_expected.to be_falsey }
      end
    end
  end

  describe '#assign' do
    subject { instance.assign(derivative: :something, path: "/somewhere-else/but-not-here") }
    it { within_block_is_expected.to raise_error(Derivative::Rodeo::Exceptions::InvalidFunctionForStorageAdapterError) }
  end

  describe '#assign!' do
    subject { instance.assign!(derivative: :something, path: "/somewhere-else/but-not-here") }
    it { within_block_is_expected.to raise_error(Derivative::Rodeo::Exceptions::InvalidFunctionForStorageAdapterError) }
  end

  describe '#fetch!' do
    subject { instance.fetch!(derivative: :base_file_for_chain) }
    it { within_block_is_expected.to raise_error(Derivative::Rodeo::Exceptions::InvalidFunctionForStorageAdapterError) }
  end

  describe '#fetch' do
    subject { instance.fetch(derivative: :base_file_for_chain) }
    it { within_block_is_expected.to raise_error(Derivative::Rodeo::Exceptions::InvalidFunctionForStorageAdapterError) }
  end

  describe '#path_for_shell_commands' do
    subject { instance.path_for_shell_commands(derivative: :base_file_for_chain) }
    it { within_block_is_expected.to raise_error(Derivative::Rodeo::Exceptions::InvalidFunctionForStorageAdapterError) }
  end
end
