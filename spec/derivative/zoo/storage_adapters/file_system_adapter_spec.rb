# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Derivative::Zoo::StorageAdapters::FileSystemAdapter do
  let(:root) { Fixtures.tmp_subdir_of("file_system") }
  let(:manifest) { Derivative::Zoo::Manifest::Original.new(parent_identifier: "123", original_filename: __FILE__, derivatives: []) }
  let(:content) { "Hello World\nWelcome to Where Ever You Are\n" }

  let(:instance) { described_class.new(manifest: manifest, root: root) }
  subject { instance }

  it { is_expected.to be_a(Derivative::Zoo::StorageAdapters::Base) }
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

  describe '#assign!' do
    context 'when given a block' do
      it "writes the results of the block" do
        expect do
          instance.assign!(derivative: :text) { content }
        end.to change { instance.exists?(derivative: :text) }.from(false).to(true)
      end
    end

    context 'when given a path' do
      it 'writes the content of the given path' do
        expect do
          instance.assign!(derivative: :text, path: __FILE__)
        end.to change { instance.exists?(derivative: :text) }.from(false).to(true)
      end
    end

    context 'when given a path and a block' do
      it "raises Exceptions::ConflictingMethodArgumentsError" do
        expect do
          instance.assign!(derivative: :text, path: __FILE__) { content }
        end.to raise_exception(Derivative::Zoo::Exceptions::ConflictingMethodArgumentsError)
      end
    end
  end

  describe '#read' do
    subject { instance.read(derivative: :text) }

    context 'when the file does not exist' do
      it { within_block_is_expected.to raise_exception(Errno::ENOENT) }
    end

    context 'when the file exists' do
      before { instance.assign!(derivative: :text) { content } }

      it "returns the contents of the file" do
        expect(subject).to eq(content)
      end
    end
  end
end
