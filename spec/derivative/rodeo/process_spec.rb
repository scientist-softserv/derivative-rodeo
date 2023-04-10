# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Derivative::Rodeo::Process do
  let(:derivative) { double(Derivative::Rodeo::Type::BaseType, generate_for: false) }
  let(:arena) { double(Derivative::Rodeo::Arena, local_demand!: true, remote_pull: false, process_next_chain_link_after!: false, local_exists?: false) }
  subject(:instance) { described_class.new(derivative: derivative, arena: arena) }
  let(:handle) { :handle }

  it { is_expected.to delegate_method(:local_demand!).to(:arena) }
  it { is_expected.to delegate_method(:local_exists?).to(:arena) }
  it { is_expected.to delegate_method(:remote_pull).to(:arena) }
  it { is_expected.to delegate_method(:process_next_chain_link_after!).to(:arena) }
  it { is_expected.to delegate_method(:generate_for).to(:derivative) }

  describe ".call" do
    subject { described_class.call(derivative: derivative, arena: arena) }

    context 'when local exists in arena' do
      it "returns a handle" do
        expect(arena).to receive(:local_exists?).with(derivative: derivative).and_return(true)
        subject
        expect(arena).to have_received(:local_demand!).with(derivative: derivative)
        expect(arena).not_to have_received(:remote_pull)
        expect(derivative).not_to have_received(:generate_for)
        expect(arena).to have_received(:process_next_chain_link_after!).with(derivative: derivative)
      end
    end
    context 'when local does not exist in arena' do
      context 'when remote exists for arena' do
        it "returns a handle" do
          expect(arena).to receive(:remote_pull).with(derivative: derivative).and_return(handle)
          subject
          expect(arena).to have_received(:local_exists?)
          expect(derivative).not_to have_received(:generate_for)
          expect(arena).to have_received(:process_next_chain_link_after!).with(derivative: derivative)
        end
      end

      context 'when remote does not exist for arena' do
        it "returns a handle" do
          expect(derivative).to receive(:generate_for).with(arena: arena).and_return(handle)
          subject
          expect(arena).to have_received(:remote_pull)
          expect(arena).to have_received(:local_exists?)
          expect(arena).to have_received(:process_next_chain_link_after!).with(derivative: derivative)
        end
      end

      context 'when nothing returns a handle' do
        let(:exception) { Derivative::Rodeo::Exceptions::FailureToLocateDerivativeError.new(derivative: derivative, arena: arena) }
        it "raises a Exceptions::FailureToLocateDerivativeError" do
          expect(arena).to receive(:local_demand!).with(derivative: derivative).and_raise(exception)
          expect { subject }.to raise_exception(exception.class)

          expect(derivative).to have_received(:generate_for)
          expect(arena).to have_received(:remote_pull)
          expect(arena).to have_received(:local_exists?)
          expect(arena).not_to have_received(:process_next_chain_link_after!)
        end
      end
    end
  end
end
