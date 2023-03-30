# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SpaceStone::Derivatives::Repository do
  let(:repository) { described_class.new(manifest: manifest) }
  let(:manifest) { SpaceStone::Derivatives::Manifest.new(parent_identifier: "123", original_filename: "abc", derivatives: []) }
  describe "local_path_for!" do
    it "raises Exceptions::NotFoundError when the derivative for the given identifier does not exist" do
      allow(repository).to receive(:local_path_for).and_return(nil)
      expect { repository.local_path_for!(derivative: :hocr) }.to(
        raise_error SpaceStone::Derivatives::Exceptions::NotFoundError
      )
    end
  end
end
