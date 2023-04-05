# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SpaceStone::Derivatives::StorageAdapters::FileSystem do
  let(:root) { Fixtures.tmp_subdir_of("file_system") }
  let(:manifest) { SpaceStone::Derivatives::Manifest::Original.new(parent_identifier: "123", original_filename: __FILE__, derivatives: []) }
  let(:content) { "Hello World\nWelcome to Where Ever You Are\n" }

  let(:instance) { described_class.new(manifest: manifest, root: root) }
  subject { instance }

  it { is_expected.to be_a(SpaceStone::Derivatives::StorageAdapters::Base) }
  it { is_expected.to respond_to(:exists?) }

  describe '#to_hash' do
    it "has the :directory_name, :manifest, :name, and :root keys" do
      expect(instance.to_hash.keys).to eq([:directory_name, :manifest, :name, :root])
    end
  end

  describe '#to_sym' do
    subject { instance.to_sym }
    it { is_expected.to eq(:file_system) }
  end

  describe '#write' do
    it "yields a block for writing content" do
      expect do
        instance.write(derivative: :text) { content }
      end.to change { instance.exists?(derivative: :text) }.from(false).to(true)
    end
  end

  describe '#read' do
    # TODO: Should this be a NullHandle?
    it "returns nil when the file does not exist" do
      expect(instance.read(derivative: :text)).to be_falsey
    end

    it "returns the content of the file when it exists" do
      instance.write(derivative: :text) { content }

      expect(instance.read(derivative: :text)).to eq(content)
    end
  end
end
