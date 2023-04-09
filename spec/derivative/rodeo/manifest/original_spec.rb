# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Derivative::Rodeo::Manifest::Original do
  let(:manifest) { described_class.new(parent_identifier: 'abc', original_filename: 'def.jpg', derivatives: derivatives) }
  let(:derivatives) { [:hocr, "alto"] }

  subject { manifest }

  it { is_expected.to respond_to :parent_identifier }
  it { is_expected.to respond_to :to_hash }
  it { is_expected.to respond_to :identifier }
  it { is_expected.to respond_to :original_filename }
  it { is_expected.to respond_to :derivatives }

  describe '#derivatives' do
    it "symbolizes the provided values" do
      expect(manifest.derivatives.all? { |d| d.is_a?(Symbol) }).to be_truthy
    end
  end

  describe '#to_hash' do
    it "has the keys :parent_identifier, :original_filename, and :derivatives" do
      expect(manifest.to_hash.keys).to eq([:parent_identifier, :original_filename, :derivatives])
    end
  end

  describe '#<=>' do
    let(:same_manifest) { described_class.new(parent_identifier: 'abc', original_filename: 'def.jpg', derivatives: derivatives) }
    let(:other_manifest) { described_class.new(parent_identifier: 'ghi', original_filename: 'def.jpg', derivatives: derivatives) }

    it "compares the work identifier and the original file name" do
      expect(manifest == same_manifest).to be_truthy
      expect(manifest.object_id == same_manifest.object_id).to be_falsey
      expect(manifest == other_manifest).to be_falsey
      expect(manifest.object_id == other_manifest.object_id).to be_falsey
    end
  end
end
