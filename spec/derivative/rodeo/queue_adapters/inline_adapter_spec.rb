# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Derivative::Rodeo::QueueAdapters::InlineAdapter do
  subject(:instance) { described_class.new }

  it { is_expected.to be_a Derivative::Rodeo::QueueAdapters::Base }

  describe '#enqueue' do
    let(:arena) { Fixtures.arena }
    it 'sends the rodeo an .process_derivative message with a contextual message' do
      expect(Derivative::Rodeo).to receive(:process_derivative).with(json: kind_of(String), config: arena.config)
      instance.enqueue(derivative_to_process: :hocr, arena: arena)
    end
  end

  describe '#to_hash' do
    subject { instance.to_hash }
    it { is_expected.to eq({ name: :inline }) }
  end
end
