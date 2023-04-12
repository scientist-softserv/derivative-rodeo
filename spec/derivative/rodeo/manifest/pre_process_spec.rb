# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Derivative::Rodeo::Manifest::PreProcess do
  subject(:manifest) { Fixtures.manifest }

  it { is_expected.to respond_to :to_hash }
  it { is_expected.to delegate_method(:parent_identifier).to(:identifier) }
  it { is_expected.to delegate_method(:original_filename).to(:identifier) }
  it { is_expected.to delegate_method(:directory_slugs).to(:identifier) }
  it { is_expected.to respond_to :mime_type }
  it { is_expected.to respond_to :mime_type= }
  it { is_expected.to respond_to :path_to_original }
  it { is_expected.to respond_to :derivatives }

  describe '#derivatives' do
    it "have all symbol keys and string values" do
      manifest.derivatives.each do |key, value|
        expect(key).to be_a Symbol
        expect(value).to be_a String
      end
    end
  end

  describe '#to_hash' do
    it "has the keys :parent_identifier, :original_filename, and :derivatives" do
      expect(manifest.to_hash.keys).to eq([:name, :derivatives, :mime_type, :original_filename, :parent_identifier, :path_to_original])
    end
  end

  describe '#path_to' do
    subject { manifest.path_to(derivative: derivative) }

    context 'when :original' do
      let(:derivative) { :original }
      it { is_expected.to eq(manifest.path_to_original) }
    end

    context 'when a declared derivative is associated with the manifest' do
      let(:derivative) { manifest.derivatives.keys.first }

      it "is expected to be the declared path" do
        path = manifest.derivatives.values.first
        expect(path).not_to be_nil
        expect(subject).to eq(path)
      end
    end

    context 'when a derivative is not associated with the manifest' do
      let(:derivative) { :obviously_missing }
      it { is_expected.to eq(nil) }
    end
  end
end
