# frozen_string_literal: true

require 'spec_helper'
require 'derivative/rodeo/utilities/url'

RSpec.describe Derivative::Rodeo::Utilities::Url do
  describe '.read' do
    context 'when the URL does not resolve' do
      xit "raises an exception"
    end

    context 'when the URL resolves' do
      xit "returns the body of the URL"
    end
  end

  describe '.exists?' do
    context 'when the URL redirects to another URL' do
      xit { is_expected.to be_truthy }
    end

    context 'when the URL response is 200' do
      xit { is_expected.to be_truthy }
    end

    context 'when we exhaust our allowed redirects' do
      xit { is_expected.to be_falsey }
    end

    context 'when the URL is not valid' do
      xit { within_block_is_expected.to raise_error }
    end
  end
end
