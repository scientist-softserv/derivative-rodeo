# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Derivative::Zoo::TextExtractors::Alto do
  let(:altoxsd) do
    xsdpath = Fixtures.path_for('alto-2-0.xsd')
    Nokogiri::XML::Schema(File.read(xsdpath))
  end

  let(:page_prefix) { '<Page ID="ID1" PHYSICAL_IMG_NR="1"' }

  let(:words) do
    [
      { word: "If", coordinates: [52, 13, 11, 14] },
      { word: "you", coordinates: [69, 17, 31, 14] },
      { word: "are", coordinates: [108, 17, 28, 10] },
      { word: "a", coordinates: [143, 17, 8, 10] },
      { word: "friend,", coordinates: [158, 13, 56, 16] },
      { word: "you", coordinates: [51, 39, 31, 14] },
      { word: "speak", coordinates: [90, 35, 50, 18] },
      { word: "the", coordinates: [146, 35, 28, 14] },
      { word: "password,", coordinates: [182, 35, 85, 18] },
      { word: "and", coordinates: [51, 57, 30, 14] },
      { word: "the", coordinates: [89, 57, 28, 14] },
      { word: "doors", coordinates: [124, 57, 48, 14] },
      { word: "will", coordinates: [180, 57, 28, 14] },
      { word: "open.", coordinates: [216, 61, 47, 14] }
    ]
  end

  describe '.to_alto' do
    subject(:output) { described_class.to_alto(words: words, width: 12_000, height: 9600) }

    it "creates alto given width, height, words" do
      expect(output.class).to be String
      expect(output).to include '<alto'
      expect(output).to include '<String'
      expect(output).to include page_prefix + ' HEIGHT="9600" WIDTH="12000"'
      expect(output).to include "<String CONTENT=\"doors\" WIDTH=\"48\" HEIGHT=\"14\" HPOS=\"124\" VPOS=\"57\"></String>"

      expect(Nokogiri::XML(output).errors.empty?).to be true
    end

    xit "makes alto 2.0 that validates" do
      renderer = described_class.new(12_000, 9600)
      output = renderer.to_alto(words)
      document = Nokogiri::XML(output)
      altoxsd.validate(document)
    end
  end
end
