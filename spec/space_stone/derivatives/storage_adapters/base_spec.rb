# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SpaceStone::Derivatives::StorageAdapters::Base do
  describe 'when included in an adapter class' do
    let(:klass) { Class.new { include SpaceStone::Derivatives::StorageAdapters::Base } }
    context "the class's instance" do
      subject { klass.new }

      it { is_expected.to be_a SpaceStone::Derivatives::StorageAdapters::Base }
      it { is_expected.to respond_to :exists? }
      it { is_expected.to respond_to :read }
      it { is_expected.to respond_to :write }
    end
  end
end
