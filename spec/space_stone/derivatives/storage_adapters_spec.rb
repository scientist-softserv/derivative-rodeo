# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SpaceStone::Derivatives::StorageAdapters do
  let(:manifest) { SpaceStone::Derivatives::Manifest::Original.new(parent_identifier: "abc", original_filename: "hello.jpg", derivatives: []) }

  describe '.for' do
    subject(:instance) { described_class.for(manifest: manifest, adapter: adapter) }

    context 'when adapter is a symbol' do
      let(:adapter) { :file_system }

      it { is_expected.to be_a SpaceStone::Derivatives::StorageAdapters::FileSystem }
    end

    context 'when adapter is a hash' do
      let(:root) { Fixtures.tmp_subdir_of("file_system") }
      let(:adapter) { { name: :file_system, root: root } }

      it { is_expected.to be_a SpaceStone::Derivatives::StorageAdapters::FileSystem }

      it 'uses the provide root' do
        expect(instance.root).to eq(root)
      end
    end
  end
end
