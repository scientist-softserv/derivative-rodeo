# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SpaceStone::Derivatives::Manifest::Derived do
  let(:original) { SpaceStone::Derivatives::Manifest::Original.new(parent_identifier: 'abc', original_filename: 'def.jpg', derivatives: []) }
  let(:derived) { described_class.new(original: original, derived: :split_pdf, index: 0, derivatives: derivatives) }
  let(:derivatives) { [:ocr] }

  subject { derived }

  it { is_expected.to respond_to :original }
  it { is_expected.to respond_to :to_hash }
  it { is_expected.to respond_to :identifier }
  it { is_expected.to respond_to :derived }
  it { is_expected.to respond_to :index }
  it { is_expected.to respond_to :derivatives }

  describe '#derivatives' do
    it "symbolizes the provided values" do
      expect(derived.derivatives.all? { |d| d.is_a?(Symbol) }).to be_truthy
    end
  end

  describe '#to_hash' do
    it "has the keys :parent_identifier, :original_filename, and :derivatives" do
      expect(derived.to_hash.keys).to eq([:derived, :index, :original, :derivatives])
    end
  end

  describe '#<=>' do
    let(:same_derived) { described_class.new(original: original, derived: :split_pdf, index: 0, derivatives: derivatives) }
    let(:other_derived) { described_class.new(original: original, derived: :split_pdf, index: 1, derivatives: derivatives) }
    let(:other_original) { SpaceStone::Derivatives::Manifest::Original.new(parent_identifier: 'ghi', original_filename: 'def.jpg', derivatives: []) }
    let(:derived_from_other_manifest) { described_class.new(original: other_original, derived: :split_pdf, index: 0, derivatives: derivatives) }

    it "compares the work identifier and the original file name" do
      expect(derived == same_derived).to be_truthy
      expect(derived.object_id == same_derived.object_id).to be_falsey
      expect(derived == other_derived).to be_falsey
      expect(derived.object_id == other_derived.object_id).to be_falsey
      expect(derived == derived_from_other_manifest).to be_falsey
      expect(derived.object_id == derived_from_other_manifest.object_id).to be_falsey
    end
  end
end
