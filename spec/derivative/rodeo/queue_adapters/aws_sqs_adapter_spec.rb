# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Derivative::Rodeo::QueueAdapters::AwsSqsAdapter do
  let(:arena) { Fixtures.pre_processing_arena }
  let(:derivative) { Derivative::Rodeo::Type::HocrType.new(arena: arena) }
  let(:client) { double(Aws::SQS::Client) }
  subject(:instance) { described_class.new(client: client) }

  it { is_expected.not_to respond_to :region= }
  it { is_expected.to respond_to :region }
  it { is_expected.to respond_to :queue_name }
  it { is_expected.to respond_to :queue_name= }

  describe '#message_for' do
    subject { instance.message_for(arena: arena, derivative: derivative) }

    it { is_expected.to respond_to :to_json }

    xit "is a hash with the arena and derivative information" do
      expect(subject).to(
        eq({
             derivative: :hocr,
             manifest: arena.manifest.to_hash,
             queue: { name: :aws_sqs, region: instance.region, queue_name: instance.queue_name }
           })
      )
    end
  end

  describe '#enqueue'
end
