# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Derivative::Zoo::QueueAdapters::InlineAdapter do
  let(:processor) { double(Derivative::Zoo::Process, call: true) }
  subject(:instance) { described_class.new(processor: processor) }

  it { is_expected.to be_a Derivative::Zoo::QueueAdapters::Base }

  describe '#enqueue' do
    let(:environment) { double(Derivative::Zoo::Environment) }
    it 'sends the processor a #call message with the given derivative and environment' do
      instance.enqueue(derivative: :hocr, environment: environment)
      expect(processor).to have_received(:call).with(derivative: :hocr, environment: environment)
    end
  end

  describe '#to_hash' do
    subject { instance.to_hash }
    it { is_expected.to eq({ name: :inline }) }
  end
end
