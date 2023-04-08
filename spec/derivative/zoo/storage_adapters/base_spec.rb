# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Derivative::Zoo::StorageAdapters::Base do
  describe 'when included in an adapter class' do
    let(:klass) { Class.new { include Derivative::Zoo::StorageAdapters::Base } }
    context "the class's instance" do
      subject { klass.new }

      it { is_expected.to be_a Derivative::Zoo::StorageAdapters::Base }
      it { is_expected.to respond_to :exists? }
      it { is_expected.to respond_to :path }
      it { is_expected.to respond_to :assign! }
      it { is_expected.to respond_to :pull }
      it { is_expected.to respond_to :pull! }
    end
  end
end