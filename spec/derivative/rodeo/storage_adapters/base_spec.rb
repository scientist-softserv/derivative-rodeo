# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Derivative::Rodeo::StorageAdapters::Base do
  describe 'when included in an adapter class' do
    let(:klass) { Class.new { include Derivative::Rodeo::StorageAdapters::Base } }
    context "the class's instance" do
      subject { klass.new }

      it { is_expected.to be_a Derivative::Rodeo::StorageAdapters::Base }
      it { is_expected.to respond_to :assign }
      it { is_expected.to respond_to :assign! }
      it { is_expected.to respond_to :demand_path_for! }
      it { is_expected.to respond_to :exists? }
      it { is_expected.to respond_to :fetch }
      it { is_expected.to respond_to :fetch! }
      it { is_expected.to respond_to :path }
      it { is_expected.to respond_to :path_for_shell_commands }
      it { is_expected.to respond_to :path_to_storage }
      it { is_expected.to respond_to :to_sym }
      it { is_expected.to respond_to :to_hash }
    end
  end
end
