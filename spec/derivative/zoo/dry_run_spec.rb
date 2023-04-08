# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Derivative::Zoo::DryRun do
  describe '.for' do
    let(:klass) do
      Class.new do
        def self.to_s
          "CustomClass"
        end

        def key(*_args)
          raise
        end

        def value
          raise
        end
      end
    end
    let(:object) { klass.new }
    let(:config) { double(Derivative::Zoo::Configuration, dry_run_reporter: dry_run_reporter) }
    let(:dry_run_reporter) { double(Proc, call: true) }

    it "overrides the named methods" do
      object.extend(described_class.for(method_names: [:key], contexts: { a: :b }, config: config))

      object.key(:hello, world: true)
      expect(dry_run_reporter).to have_received(:call).with("Calling CustomClass#key([:hello, {:world=>true}]) for a: :b.")

      # Just to verify that it isn't adjusting the un-named method.
      expect { object.value }.to raise_exception(StandardError)
    end
  end
end
