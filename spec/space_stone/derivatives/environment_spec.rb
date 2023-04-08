# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SpaceStone::Derivatives::Environment do
  let(:config) { Fixtures.pre_processing_config }
  subject(:environment) { Fixtures.pre_processing_environment(config: config) }

  describe 'when dry run is configured' do
    let(:config) do
      Fixtures.pre_processing_config do |cfg|
        cfg.dry_run_reporter = dry_run_reporter
        cfg.dry_run = true
      end
    end
    let(:dry_run_reporter) { double(Proc, call: true) }

    it "logs activity without calling" do
      expect(environment).to be_dry_run

      environment.start_processing!
      expect(dry_run_reporter).to have_received(:call).at_least(1).times
    end
  end

  describe '.for_pre_processing' do
    subject(:environment) { Fixtures.pre_processing_environment }

    it { is_expected.to be_a described_class }
  end

  describe '.for_mime_type_processing' do
    let(:environment) { Fixtures.pre_processing_environment }
    subject { described_class.for_mime_type_processing(environment: environment) }

    it "builds a chain for the given mime_type" do
      expect(SpaceStone::Derivatives::Chain).to(
        receive(:from_mime_types_for)
          .with(manifest: environment.manifest, config: kind_of(SpaceStone::Derivatives::Configuration))
          .and_call_original
      )
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
    subject(:hash) { environment.to_hash }

    it do
      expect(hash.keys).to eq([:chain, :local_storage, :manifest, :queue, :remote_storage])
    end
  end

  describe "#start_processing!" do
    let(:derivative) { environment.chain.first }

    it 'enqueues the first link in the chain' do
      expect(environment.queue).to receive(:enqueue).with(derivative: derivative, environment: environment)
      environment.start_processing!
    end
  end

  describe "#process_next_chain_link_after!" do
    let(:chain) { environment.chain.to_a }

    subject { environment.process_next_chain_link_after!(derivative: derivative) }

    context 'when given a derivative that has a next chain link' do
      let(:derivative) { chain[-2] }
      let(:next_link) { chain[-1] }

      it 'enqueues the next chain link' do
        expect(environment.queue).to receive(:enqueue).with(derivative: next_link, environment: environment)
        subject
      end

      context 'when given derivative is last in chain' do
        let(:derivative) { chain[-1] }
        subject { environment.process_next_chain_link_after!(derivative: derivative) }

        it { is_expected.to eq(:end_of_chain) }

        it "does not enqueue any further jobs" do
          expect(environment.queue).not_to receive(:enqueue)
          subject
        end
      end
      context 'when the given derivative is not part of the chain' do
        let(:derivative) { :base }

        it { within_block_is_expected.to raise_exception(SpaceStone::Derivatives::Exceptions::UnknownDerivativeRequestForChainError) }
      end
    end
  end

  describe '#remote_pull' do
    it "forward delegates to the :remote" do
      expect(environment.remote_storage).to receive(:pull).with(derivative: :hocr, to: environment.local_storage)
      environment.remote_pull(derivative: :hocr)
    end
  end
  describe '#remote_pull!' do
    it "forward delegates to the :remote" do
      expect(environment.remote_storage).to receive(:pull!).with(derivative: :hocr, to: environment.local_storage)
      environment.remote_pull!(derivative: :hocr)
    end
  end

  it { is_expected.to respond_to(:local_run_command!) }
end
