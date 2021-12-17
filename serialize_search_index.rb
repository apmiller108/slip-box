#!/usr/bin/env ruby

require 'nokogiri'
require 'json'

PATTERN = File.join('**', 'public', '**', '*.html')
PAGE_TITLE_SUFFIX = ' - notes.alex-miller.com'.freeze

documents = []

Dir.glob(PATTERN).each_with_object(documents) do |filename, docs|
  next if filename == 'public/index.html'

  doc = Nokogiri::HTML(File.open(filename))

  docs << {
    id:    filename,
    title: doc.title.gsub(PAGE_TITLE_SUFFIX, ''),
    body:  doc.css('body').text
  }
end

puts JSON(documents)
