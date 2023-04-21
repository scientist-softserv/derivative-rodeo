# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Derivative::Rodeo::Process do
  let(:derivative) { Derivative::Rodeo::Step::BaseStep }
  let(:manifest) { Fixtures.manifest }
  let(:arena) do
    double(Derivative::Rodeo::Arena, manifest: manifest, local_demand_path_for!: true, remote_fetch: false, process_next_chain_link_after!: false, local_exists?: false,
                                     logger: Derivative::Rodeo.config.logger)
  end
  subject(:instance) { described_class.new(derivative: derivative, arena: arena) }
  let(:handle) { :handle }

  it { is_expected.to delegate_method(:local_demand_path_for!).to(:arena) }
  it { is_expected.to delegate_method(:local_exists?).to(:arena) }
  it { is_expected.to delegate_method(:logger).to(:arena) }
  it { is_expected.to delegate_method(:remote_fetch).to(:arena) }
  it { is_expected.to delegate_method(:process_next_chain_link_after!).to(:arena) }
  it { is_expected.to delegate_method(:generate_for).to(:derivative) }

  describe ".call" do
    subject { described_class.call(derivative: derivative, arena: arena) }

    context 'when local exists in arena' do
      it "returns a handle" do
        expect(arena).to receive(:local_exists?).with(derivative: derivative).and_return(true)
        expect(derivative).not_to receive(:generate_for)
        subject
        expect(arena).to have_received(:local_demand_path_for!).with(derivative: derivative)
        expect(arena).not_to have_received(:remote_fetch)
        expect(arena).to have_received(:process_next_chain_link_after!).with(derivative: derivative)
      end
    end
    context 'when local does not exist in arena' do
      context 'when remote exists for arena' do
        it "returns a handle" do
          expect(derivative).not_to receive(:generate_for)
          expect(arena).to receive(:remote_fetch).with(derivative: derivative).and_return(handle)
          subject
          expect(arena).to have_received(:local_exists?)
          expect(arena).to have_received(:process_next_chain_link_after!).with(derivative: derivative)
        end
      end

      context 'when remote does not exist for arena' do
        it "returns a handle" do
          expect(derivative).to receive(:generate_for).with(arena: arena).and_return(handle)
          subject
          expect(arena).to have_received(:remote_fetch)
          expect(arena).to have_received(:local_exists?)
          expect(arena).to have_received(:process_next_chain_link_after!).with(derivative: derivative)
        end
      end

      context 'when nothing returns a handle' do
        let(:exception) { Derivative::Rodeo::Exceptions::FailureToLocateDerivativeError.new(derivative: derivative, arena: arena) }
        it "raises a Exceptions::FailureToLocateDerivativeError" do
          expect(arena).to receive(:local_demand_path_for!).with(derivative: derivative).and_raise(exception)
          expect(derivative).to receive(:generate_for).and_return(nil)

          expect { subject }.to raise_exception(exception.class)

          expect(arena).to have_received(:remote_fetch)
          expect(arena).to have_received(:local_exists?)
          expect(arena).not_to have_received(:process_next_chain_link_after!)
        end
      end
    end
  end
end
