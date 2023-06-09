# frozen_string_literal: true

require 'nokogiri'

module Derivative
  module Rodeo
    module TextExtractors
      ##
      # Responsible for converting words into a Alto XML format.
      #
      # @see .to_alto
      class Alto
        ##
        # @api public
        #
        # @param words [Array<Hash<Symbol, Object>] Each has has the keys :word and :coordinates.
        # @param width [Integer]
        # @param height [Integer]
        # @param scaling [Float]
        #
        # @return [String] a string of XML
        def self.to_alto(words:, width:, height:, scaling: 1.0)
          new(words: words, width: width, height: height, scaling: scaling).to_alto
        end

        def initialize(words:, width:, height:, scaling:)
          @words = words
          @height = height
          @width = width
          @scaling = scaling
        end

        attr_reader :words, :height, :width, :scaling

        def to_alto
          @to_alto ||= alto_page(width, height) do |xml|
            words.each do |word|
              xml.String(
                CONTENT: word[:word],
                WIDTH: scale_point(word[:coordinates][2]).to_s,
                HEIGHT: scale_point(word[:coordinates][3]).to_s,
                HPOS: scale_point(word[:coordinates][0]).to_s,
                VPOS: scale_point(word[:coordinates][1]).to_s
              ) { xml.text '' }
            end
          end.to_xml
        end

        private

        # given block to manage word generation, wrap with page/block/line
        def alto_page(pxwidth, pxheight, &block)
          builder = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
            xml.alto(xmlns: 'http://www.loc.gov/standards/alto/ns-v2#') do
              xml.Description do
                xml.MeasurementUnit 'pixel'
              end
              alto_layout(xml, pxwidth, pxheight, &block)
            end
          end
          builder
        end

        def scale_point(value)
          # NOTE: presuming non-fractional, even though ALTO 2.1
          #   specifies coordinates are xsd:float, not xsd:int,
          #   simplify to integer value for output:
          (value * @scaling).to_i
        end

        # return layout for page
        def alto_layout(xml, pxwidth, pxheight, &block)
          xml.Layout do
            xml.Page(ID: 'ID1',
                     PHYSICAL_IMG_NR: '1',
                     HEIGHT: pxheight.to_i,
                     WIDTH: pxwidth.to_i) do
              xml.PrintSpace(HEIGHT: pxheight.to_i,
                             WIDTH: pxwidth.to_i,
                             HPOS: '0',
                             VPOS: '0') do
                alto_blockline(xml, pxwidth, pxheight, &block)
              end
            end
          end
        end

        # make block line and call word-block
        def alto_blockline(xml, pxwidth, pxheight)
          xml.TextBlock(ID: 'ID1a',
                        HEIGHT: pxheight.to_i,
                        WIDTH: pxwidth.to_i,
                        HPOS: '0',
                        VPOS: '0') do
            xml.TextLine(HEIGHT: pxheight.to_i,
                         WIDTH: pxwidth.to_i,
                         HPOS: '0',
                         VPOS: '0') do
              yield(xml)
            end
          end
        end
      end
    end
  end
end
