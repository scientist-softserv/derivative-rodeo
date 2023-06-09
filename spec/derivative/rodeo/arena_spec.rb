# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Derivative::Rodeo::Arena do
  let(:config) { Fixtures.config }
  subject(:arena) { Fixtures.arena(config: config) }

  describe 'when dry run is configured' do
    let(:config) do
      Fixtures.config do |cfg|
        cfg.dry_run_reporter = dry_run_reporter
        cfg.dry_run = true
      end
    end
    let(:dry_run_reporter) { double(Proc, call: true) }

    it "logs activity without calling" do
      expect(arena).to be_dry_run

      arena.start_processing!
      expect(dry_run_reporter).to have_received(:call).at_least(1).times
    end
  end

  describe '.for_pre_processing' do
    subject(:arena) { Fixtures.arena }

    it { is_expected.to be_a described_class }
  end

  describe '.for_derived' do
    let(:parent_arena) { Fixtures.arena }
    subject(:arena) do
      described_class.for_derived(parent_arena: parent_arena,
                                  path_to_base_file_for_chain: __FILE__,
                                  first_spawn_step_name: :page_image,
                                  index: 0,
                                  derivatives: [:page_image])
    end

    it 'will assign the given derived path to the derived name' do
      # See the PdfSplitStep for further discussion on the directory structure.
      path_to_spawned_file = File.join(parent_arena.local_storage.directory_name, "page_image", "0", "base_file_for_chain")
      expect do
        arena
      end.to change { File.file?(path_to_spawned_file) }
    end

    it { is_expected.to be_a described_class }
  end

  describe '.new' do
    it "is a private method (don't call it directly)" do
      expect(described_class.private_methods).to include(:new)
    end
  end

  describe "#to_hash keys" do
    subject(:hash) { arena.to_hash.keys }

    it { is_expected.to eq([:chain, :local_storage, :manifest, :queue, :remote_storage]) }
  end

  describe "#start_processing!" do
    let(:derivative) { arena.chain.first }

    it 'enqueues the first link in the chain' do
      expect(arena.queue).to receive(:enqueue).with(derivative_to_process: derivative, arena: arena)
      arena.start_processing!
    end
  end

  describe "#process_next_chain_link_after!" do
    let(:chain) { arena.chain.to_a }

    subject { arena.process_next_chain_link_after!(derivative: derivative) }

    context 'when given a derivative that has a next chain link' do
      let(:derivative) { chain[-2] }
      let(:next_link) { chain[-1] }

      it 'enqueues the next chain link' do
        expect(arena.queue).to receive(:enqueue).with(derivative_to_process: next_link, arena: arena)
        subject
      end

      context 'when given derivative is last in chain' do
        let(:derivative) { chain[-1] }
        subject { arena.process_next_chain_link_after!(derivative: derivative) }

        it { is_expected.to eq(:end_of_chain) }

        it "does not enqueue any further jobs" do
          expect(arena.queue).not_to receive(:enqueue)
          subject
        end
      end
      context 'when the given derivative is not part of the chain' do
        let(:derivative) { :base }

        it { within_block_is_expected.to raise_exception(Derivative::Rodeo::Exceptions::UnknownDerivativeRequestForChainError) }
      end
    end
  end

  describe '#remote_fetch' do
    it "forward delegates to the :remote" do
      expect(arena.local_storage).to receive(:fetch).with(derivative: :hocr, from: arena.remote_storage)
      arena.remote_fetch(derivative: :hocr)
    end
  end
  describe '#remote_fetch!' do
    it "forward delegates to the :remote" do
      expect(arena.local_storage).to receive(:fetch!).with(derivative: :hocr, from: arena.remote_storage)
      arena.remote_fetch!(derivative: :hocr)
    end
  end

  it { is_expected.to respond_to(:local_run_command!) }
end
