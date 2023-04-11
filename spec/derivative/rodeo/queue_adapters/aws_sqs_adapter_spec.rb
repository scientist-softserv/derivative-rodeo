# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Derivative::Rodeo::QueueAdapters::AwsSqsAdapter do
  let(:arena) { Fixtures.pre_processing_arena }
  let(:derivative) { Derivative::Rodeo::Type::HocrType.new(arena: arena) }
  let(:s3_queue) { double(queue_url: "somewhere-over-the-rainbow") }
  let(:client) { double(Aws::SQS::Client, send_message: true, get_queue_url: s3_queue) }
  subject(:instance) { described_class.new(client: client) }

  it { is_expected.not_to respond_to :region= }
  it { is_expected.to respond_to :region }
  it { is_expected.to respond_to :queue_name }
  it { is_expected.to respond_to :queue_name= }

  describe '.client' do
    subject { described_class.client }

    # This test takes 3 seconds on an M1 Apple Silicon chip; is that worth running?
    xit { is_expected.to be_a(::Aws::SQS::Client) }
  end

  describe '#enqueue' do
    subject { instance.enqueue(arena: arena, derivative: derivative) }
    let(:message_body) { %({hello:"world"}) }

    # Yes this is testing the integration of a bunch of mocked things; but sometimes that's what you
    # do.
    it 'sends a message to the client with queue_url and message body' do
      allow(Derivative::Rodeo::Message).to(
        receive(:to_json)
          .with(arena: arena, derivative: derivative, queue: instance)
          .and_return(message_body)
      )

      subject

      expect(client).to(
        have_received(:send_message)
          .with(queue_url: s3_queue.queue_url, message_body: message_body)
      )
    end
  end

  describe '#to_hash' do
    subject { instance.to_hash }

    it {
      is_expected.to(eq({ name: :aws_sqs,
                          region: described_class.region,
                          queue_name: described_class.queue_name }))
    }
  end
end
