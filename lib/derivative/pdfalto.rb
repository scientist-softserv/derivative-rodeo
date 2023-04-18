# frozen_string_literal: true

require 'nokogiri'

pdf_path = ARGV[0]
filename = File.basename(pdf_path, File.extname(pdf_path))
output_dir = File.join(File.dirname(pdf_path), filename)
Dir.mkdir(output_dir) unless Dir.exist?(output_dir)

# Run the pdfalto command line tool to convert the PDF to XML
# Assumes that pdfalto is in your PATH
`pdfalto -noImage #{pdf_path}`
output_path = File.join(File.dirname(pdf_path), "#{File.basename(pdf_path, '.pdf')}.xml")
output = File.read(output_path)
doc = Nokogiri::XML(output)

# Find all the <Page> elements in the XML file
pages = doc.xpath('//alto:Page', 'alto' => 'http://www.loc.gov/standards/alto/ns-v3#')

# Write each page to a separate XML file
pages.each_with_index do |page, index|
  output_path = "#{output_dir}/#{filename}#{index + 1}.xml"

  # Create a new xml document for each page
  page_doc = Nokogiri::XML("<?xml version='1.0' encoding='UTF-8' standalone='yes'?>#{page}")
  File.write(output_path, page_doc.to_xml)
end

# Clean up extra files
File.delete("#{filename}.xml") if File.exist?("#{filename}.xml")
File.delete("#{filename}_metadata.xml") if File.exist?("#{filename}_metadata.xml")
