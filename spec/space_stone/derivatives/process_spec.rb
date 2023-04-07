# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SpaceStone::Derivatives::Process do
  let(:derivative) { double(SpaceStone::Derivatives::Types::BaseType, generate_for: false) }
  let(:environment) { double(SpaceStone::Derivatives::Environment, local_demand!: true, remote_pull: false, process_next_chain_link_after!: false, local_exists?: false) }
  subject(:instance) { described_class.new(derivative: derivative, environment: environment) }
  let(:handle) { :handle }

  it { is_expected.to delegate_method(:local_exists?).to(:environment) }
  it { is_expected.to delegate_method(:remote_pull).to(:environment) }
  it { is_expected.to delegate_method(:process_next_chain_link_after!).to(:environment) }
  it { is_expected.to delegate_method(:generate_for).to(:derivative) }
  it { is_expected.to delegate_method(:local_demand!).to(:environment) }

  describe ".call" do
    subject { described_class.call(derivative: derivative, environment: environment) }

    context 'when local exists in environment' do
      it "returns a handle" do
        expect(environment).to receive(:local_exists?).with(derivative: derivative).and_return(true)
        subject
        expect(environment).to have_received(:local_demand!).with(derivative: derivative)
        expect(environment).not_to have_received(:remote_pull)
        expect(derivative).not_to have_received(:generate_for)
        expect(environment).to have_received(:process_next_chain_link_after!).with(derivative: derivative)
      end
    end
    context 'when local does not exist in environment' do
      context 'when remote exists for environment' do
        it "returns a handle" do
          expect(environment).to receive(:remote_pull).with(derivative: derivative).and_return(handle)
          subject
          expect(environment).to have_received(:local_exists?)
          expect(derivative).not_to have_received(:generate_for)
          expect(environment).to have_received(:process_next_chain_link_after!).with(derivative: derivative)
        end
      end

      context 'when remote does not exist for environment' do
        it "returns a handle" do
          expect(derivative).to receive(:generate_for).with(environment: environment).and_return(handle)
          subject
          expect(environment).to have_received(:remote_pull)
          expect(environment).to have_received(:local_exists?)
          expect(environment).to have_received(:process_next_chain_link_after!).with(derivative: derivative)
        end
      end

      context 'when nothing returns a handle' do
        let(:exception) { SpaceStone::Derivatives::Exceptions::FailureToLocateDerivativeError.new(derivative: derivative, environment: environment) }
        it "raises a Exceptions::FailureToLocateDerivativeError" do
          expect(environment).to receive(:local_demand!).with(derivative: derivative).and_raise(exception)
          expect { subject }.to raise_exception(exception.class)

          expect(derivative).to have_received(:generate_for)
          expect(environment).to have_received(:remote_pull)
          expect(environment).to have_received(:local_exists?)
          expect(environment).not_to have_received(:process_next_chain_link_after!)
        end
      end
    end
  end
end
