# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Derivative::Rodeo::StorageAdapters::FileSystemAdapter do
  let(:root) { Fixtures.tmp_subdir_of("file_system") }
  let(:manifest) { Fixtures.manifest(work_identifier: "123", file_set_filename: __FILE__, derivatives: []) }
  let(:content) { "Hello World\nWelcome to Where Ever You Are\n" }

  subject(:instance) { described_class.new(manifest: manifest, root: root) }

  it { is_expected.to be_a(Derivative::Rodeo::StorageAdapters::Base) }
  it { is_expected.to respond_to(:exists?) }

  # TODO: Add Shared Adapter Spec

  describe '#assign' do
    let(:utility) { double(FileUtils, mkdir_p: true, copy_file: true, open: true) }
    context 'when given a path' do
      it 'will move the file at the given path to the storage location' do
        storage_path = instance.path_to_storage(derivative: :wonky)
        instance.assign(derivative: :wonky, path: __FILE__, utility: utility)
        expect(utility).to have_received(:mkdir_p).with(File.dirname(storage_path))
        expect(utility).to have_received(:copy_file).with(__FILE__, storage_path)
      end
    end
    context 'when given a block' do
      it 'will write the contents of the results of the block to the file system' do
        body = "Hello World"
        storage_path = instance.path_to_storage(derivative: :wonky)
        allow(File).to receive(:write)
        instance.assign(derivative: :wonky, utility: utility) { body }
        expect(File).to have_received(:write).with(storage_path, body)
      end
    end

    context 'when given both a block and a path' do
      subject { instance.assign(derivative: :wonky, path: __FILE__) { "Content to Write\n" } }

      it { within_block_is_expected.to raise_error Derivative::Rodeo::Exceptions::AttemptedToAssignPathAndBlockError }
    end
  end

  describe '#directory_exists?' do
    let(:relative_dir_name) { 'hello' }
    subject { instance.directory_exists?(relative_dir_name) }

    context 'when the relative directory exists' do
      before { Dir.mkdir(File.join(instance.directory_name, relative_dir_name)) }
      it { is_expected.to be_truthy }
    end

    context 'when the relative directory does not exist' do
      it { is_expected.to be_falsey }
    end
  end

  describe '#to_hash keys' do
    subject { instance.to_hash.keys }
    it { is_expected.to eq([:manifest, :name, :root]) }
  end

  describe '#to_sym' do
    subject { instance.to_sym }
    it { is_expected.to eq(:file_system) }
  end

  describe '#fetch!' do
    subject { instance.fetch(from: from, derivative: :base_file_for_chain) }
    let(:from) { double(described_class, demand_path_for!: false) }
    let(:expected_path) { instance.path_to_storage(derivative: :base_file_for_chain) }

    context 'when the file already exists in storage' do
      it "returns the path that file" do
        # Ensure that we have the file where we said we would.
        File.open(expected_path, "wb") { |f| f.puts content }

        expect(subject).to eq(expected_path)
        expect(from).not_to have_received(:demand_path_for!)
      end
    end

    context 'when the file already does not exists locally' do
      it 'will fetch from the remote file' do
        allow(from).to receive(:demand_path_for!).and_return(__FILE__)

        expect(subject).to eq(expected_path)
        expect(instance.demand_path_for!(derivative: :base_file_for_chain)).to be_truthy
        expect(File.read(expected_path)).to eq(File.read(__FILE__))
      end
    end
  end
end
