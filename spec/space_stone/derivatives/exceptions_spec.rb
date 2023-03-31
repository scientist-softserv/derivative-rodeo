# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SpaceStone::Derivatives::Exceptions do
  describe "ProcessorError" do
    let(:processor) { double(SpaceStone::Derivatives::Processor) }

    it "aggregates multiple errors" do
      errors = []
      ["Hello", "Good-Bye"].each do |message|
        raise message
      rescue => e
        errors << e
      end

      exception = described_class::ProcessorError.new(processor: processor, errors: errors)

      expect(exception.backtrace).to be_a(Enumerable)
    end
  end
end
