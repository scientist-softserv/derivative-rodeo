# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Derivative::Rodeo::Message do
  let(:derivative) { :hocr }
  let(:arena) { Fixtures.pre_processing_arena }
  let(:queue) { Derivative::Rodeo::QueueAdapters.for(adapter: :inline) }
  describe '.to_json' do
    subject { described_class.to_json(derivative: derivative, arena: arena, queue: queue) }
    it { is_expected.to be_a String }
  end

  describe '#to_hash' do
    subject(:hash) { described_class.new(arena: arena, derivative: derivative, queue: queue).to_hash }

    it 'has symbolic keys that can be used to invoke a new task' do
      expect(hash).to eq({
                           derivative: derivative.to_sym,
                           queue: queue.to_hash,
                           manifest: arena.manifest.to_hash,
                           local_storage: arena.local_storage.to_hash,
                           remote_storage: arena.remote_storage.to_hash
                         })
    end
  end
end
