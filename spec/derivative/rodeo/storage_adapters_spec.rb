# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Derivative::Rodeo::StorageAdapters do
  let(:manifest) { Derivative::Rodeo::Manifest::Original.new(parent_identifier: "abc", file_set_filename: "hello.jpg", derivatives: []) }

  describe '.for' do
    subject(:instance) { described_class.for(manifest: manifest, adapter: adapter) }

    context 'when adapter is a symbol' do
      let(:adapter) { :file_system }

      it { is_expected.to be_a described_class::FileSystemAdapter }
    end

    context 'when adapter is a hash' do
      let(:root) { Fixtures.tmp_subdir_of("file_system") }
      let(:adapter) { { name: :file_system, root: root } }

      it { is_expected.to be_a described_class::FileSystemAdapter }

      it 'uses the provide root' do
        expect(instance.root).to eq(root)
      end
    end

    context 'when you provide an unknown adapter format' do
      let(:adapter) { 123 }

      it { within_block_is_expected.to raise_exception Derivative::Rodeo::Exceptions::UnexpectedStorageAdapterNameError }
    end

    context 'when you provide an unregistered adapter name' do
      let(:adapter) { :so_very_missing }

      it { within_block_is_expected.to raise_exception NameError }
    end
  end
end
