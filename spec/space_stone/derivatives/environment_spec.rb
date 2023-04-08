# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SpaceStone::Derivatives::Environment do
  describe 'configuration' do
    subject { described_class }
    it { is_expected.to respond_to :local_adapter_name }
    it { is_expected.to respond_to :local_adapter_name= }
    it { is_expected.to respond_to :remote_adapter_name }
    it { is_expected.to respond_to :remote_adapter_name= }
    it { is_expected.to respond_to :queue_adapter_name }
    it { is_expected.to respond_to :queue_adapter_name= }
  end

  let(:original) { SpaceStone::Derivatives::Manifest::Original.new(parent_identifier: "abc", original_filename: 'efg.png', derivatives: [:hocr]) }
  let(:original_environment) { described_class.for_original(manifest: original, local: :file_system, remote: :file_system, queue: :inline) }

  describe '.for_original' do
    subject { original_environment }

    it { is_expected.to be_a described_class }
    it { is_expected.to respond_to :manifest }
    it { is_expected.to respond_to :local }
    it { is_expected.to respond_to :remote }
    it { is_expected.to respond_to :queue }
    it { is_expected.to respond_to :chain }
    it { is_expected.to respond_to :logger }

    it { is_expected.to delegate_method(:exists?).to(:local).with_prefix(true) }
    it { is_expected.to delegate_method(:assign!).to(:local).with_prefix(true) }
    it { is_expected.to delegate_method(:path).to(:local).with_prefix(true) }

    it { is_expected.to delegate_method(:mime_type).to(:manifest) }
    it { is_expected.to delegate_method(:original_filename).to(:manifest) }

    it { is_expected.to delegate_method(:exists?).to(:remote).with_prefix(true) }

    it { is_expected.to respond_to :local_demand! }
    it { is_expected.to respond_to :remote_pull! }
    it { is_expected.to respond_to :remote_pull }
  end

  describe '.for_mime_type!' do
    let(:environment) { Fixtures.pre_processing_environment }
    subject { described_class.for_mime_type(environment: environment) }

    it "builds a chain" do
      expect(SpaceStone::Derivatives::Chain).to receive(:from_mime_types_for).with(manifest: environment.manifest).and_call_original
      subject
    end
    it { is_expected.to be_a described_class }
  end

  describe '.new' do
    it "is a private method (don't call it directly)" do
      expect(described_class.private_methods).to include(:new)
    end
  end

  describe "#to_hash" do
    subject(:hash) { original_environment.to_hash }

    it do
      expect(hash.keys).to eq([:chain, :local, :manifest, :queue, :remote])
    end
  end

  describe "#process_start!" do
    let(:derivative) { original_environment.chain.first }

    it 'enqueues the first link in the chain' do
      expect(original_environment.queue).to receive(:enqueue).with(derivative: derivative, environment: original_environment)
      original_environment.process_start!
    end
  end

  describe "#process_next_chain_link_after!" do
    let(:chain) { original_environment.chain.to_a }

    subject { original_environment.process_next_chain_link_after!(derivative: derivative) }

    context 'when given a derivative that has a next chain link' do
      let(:derivative) { chain[-2] }
      let(:next_link) { chain[-1] }

      it 'enqueues the next chain link' do
        expect(original_environment.queue).to receive(:enqueue).with(derivative: next_link, environment: original_environment)
        subject
      end

      context 'when given derivative is last in chain' do
        let(:derivative) { chain[-1] }
        subject { original_environment.process_next_chain_link_after!(derivative: derivative) }

        it { is_expected.to eq(:end_of_chain) }

        it "does not enqueue any further jobs" do
          expect(original_environment.queue).not_to receive(:enqueue)
          subject
        end
      end
      context 'when the given derivative is not part of the chain' do
        let(:derivative) { :base }
        it "raises Exceptions::UnknownDerivativeRequestForChainError" do
          expect { subject }.to raise_exception(SpaceStone::Derivatives::Exceptions::UnknownDerivativeRequestForChainError)
        end
      end
    end
  end

  describe '#remote_pull' do
    it "forward delegates to the :remote" do
      expect(original_environment.remote).to receive(:pull).with(derivative: :hocr, to: original_environment.local)
      original_environment.remote_pull(derivative: :hocr)
    end
  end
  describe '#remote_pull!' do
    it "forward delegates to the :remote" do
      expect(original_environment.remote).to receive(:pull!).with(derivative: :hocr, to: original_environment.local)
      original_environment.remote_pull!(derivative: :hocr)
    end
  end
end
