# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Derivative::Rodeo::StorageAdapters::AwsS3Adapter do
  let(:bucket) { Fixtures.aws_s3_bucket }

  let(:manifest) { Fixtures.manifest }
  subject(:instance) { described_class.new(manifest: manifest, bucket: bucket) }

  describe '.resource' do
    subject { described_class.resource }
    # This test takes 3 seconds to run
    xit { is_expected.to be_a Aws::S3::Resource }
  end

  describe '#region' do
    subject { instance.region }
    it { is_expected.to be_a String }
  end

  describe '#bucket_name' do
    subject { instance.bucket_name }
    it { is_expected.to be_a String }
  end

  it { is_expected.to respond_to(:bucket) }

  describe '#exists?' do
    subject { instance.exists?(derivative: :original) }
    context 'when it exists in the bucket' do
      before { instance.bucket.object(instance.path_to_storage(derivative: :original)).upload_file(__FILE__) }
      it { is_expected.to be_truthy }
    end

    context 'when it does not exist in the bucket' do
      it { is_expected.to be_falsey }
    end
  end

  describe '#fetch!' do
    let(:remote) { double(exists?: remote_exists, path_to_storage: __FILE__) }
    let(:remote_exists) { false }
    subject { instance.fetch!(derivative: :original, from: remote) }
    let(:expected_path) { instance.path_to_storage(derivative: :original) }
    context 'when it already exists in the bucket' do
      before { instance.bucket.object(instance.path_to_storage(derivative: :original)).upload_file(__FILE__) }
      it "will be the path to the existing object" do
        expect(subject).to eq(expected_path)
      end
    end

    context 'when it does not yet exist in the bucket' do
      context 'and does not exist in the remote' do
        let(:remote_exists) { false }
        it { within_block_is_expected.to raise_error(Derivative::Rodeo::Exceptions::DerivativeNotFoundError) }
      end

      context 'and exists in the remote' do
        let(:remote_exists) { true }
        it 'will upload the remote file to the bucket' do
          expect { subject }.to change { instance.exists?(derivative: :original) }.from(false).to(true)
        end
      end
    end
  end

  describe '#path_to_storage' do
    subject { instance.path_to_storage(derivative: :original) }

    it { is_expected.to be_a String }
    it { is_expected.to eq("#{manifest.parent_identifier}/#{manifest.file_set_filename}/original") }
  end

  describe '#path_for_shell_commands' do
    before do
      # Some significant antics to ensure that we have a clean space for testing this command.
      path = nil
      begin
        path = instance.path_for_shell_commands(derivative: :original, perform_download: false)
      rescue Derivative::Rodeo::Exceptions::FileNotFoundForShellProcessing
        # This is not a problem; the file does not exist
      end
      FileUtils.rm_f(path) if path && File.file?(path)
    end

    subject { instance.path_for_shell_commands(derivative: :original) }

    context 'when the file is not in the bucket' do
      it { within_block_is_expected.to raise_error Derivative::Rodeo::Exceptions::FileNotFoundForShellProcessing }
    end

    context 'when the file is in the bucket' do
      before { instance.bucket.object(instance.path_to_storage(derivative: :original)).upload_file(__FILE__) }

      it { is_expected.to be_a(String) }

      it 'will download the file from the bucket and write it to the local system for processing' do
      end
    end
  end
end
