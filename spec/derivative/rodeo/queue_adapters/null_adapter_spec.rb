# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Derivative::Rodeo::QueueAdapters::NullAdapter do
  describe '#enqueue' do
    let(:instance) { described_class.new }
    let(:config) { Fixtures.config }
    subject { instance.enqueue(derivative_to_process: :original, arena: double(Derivative::Rodeo::Arena, config: config)) }
    it "logs the enqueing but does nothing else" do
      expect(config).to receive_message_chain('logger.debug')
      subject
    end
  end
end
