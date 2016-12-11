require 'nokogiri'
require 'open-uri'
require 'pry'

ROOT_URL = 'http://alkitab.mobi/tb'

doc = Nokogiri::HTML(open("#{ROOT_URL}"))

doc.css('.style0 a').each do |book_link|
  book = book_link.content
  chapter_doc = Nokogiri::HTML(open("#{ROOT_URL}/#{book}"))

  for chapter in 1..chapter_doc.css('.style2 a').count
    verse_doc = Nokogiri::HTML(open("#{ROOT_URL}/#{book}/#{chapter}"))

    verse_doc.css('.passage p').each do |verse_link|
      if verse_link.content.length == 0
        next
      end

      if verse_link.css('.paragraphtitle').count > 0
        puts verse_link.content
      elsif verse_link.css('span[data-begin]').count > 0
        puts verse_link.css('span.reftext').first.content
        puts verse_link.css('span[data-begin]').first.content
      end
    end
  end
end
