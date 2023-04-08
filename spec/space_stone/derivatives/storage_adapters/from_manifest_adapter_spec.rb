# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SpaceStone::Derivatives::StorageAdapters::FromManifestAdapter do
  let(:manifest) { Fixtures.pre_processing_manifest(path_to_original: __FILE__) }
  let(:instance) { described_class.new(manifest: manifest) }
  subject { instance }

  it { is_expected.to delegate_method(:path_to).to(:manifest) }

  describe '#read' do
    it 'returns the content' do
      expect(instance.read(derivative: :original)).to eq(File.read(__FILE__))
    end
  end
end
