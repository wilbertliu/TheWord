require 'nokogiri'
require 'open-uri'
require 'json'
require 'pry'

ROOT_URL = 'http://alkitab.mobi/tb'

json = { books: [] }
types = []
doc = Nokogiri::HTML(open("#{ROOT_URL}"))

types.push(doc.css("a[accesskey='4']").first[:href])
types.push(doc.css("a[accesskey='5']").first[:href])

for type_idx in 0..types.count - 1
  type_doc = Nokogiri::HTML(open("#{types[type_idx]}"))

  type_doc.css('.style0 a').each do |book_link|
    book_hash = { name: '', type: type_idx == 0 ? 'Old' : 'New', total_chapter: 0, chapters: [] }
    book = book_link.content
    chapter_doc = Nokogiri::HTML(open("#{ROOT_URL}/#{book}"))

    chapter_doc.css('.style1').each do |style_1|
      if style_1.css('strong').count == 1
        book_hash[:name] = style_1.css('strong').first.content
        break
      end
    end

    total_chapter = chapter_doc.css('.style2 a').count
    book_hash[:total_chapter] = total_chapter

    puts "Scrapping -> #{book_hash[:name]}"

    for chapter in 1..total_chapter
      chapter_hash = { number: chapter, total_verse: 0, verses: [] }
      verse_doc = Nokogiri::HTML(open("#{ROOT_URL}/#{book}/#{chapter}"))

      chapter_hash[:total_verse] = verse_doc.css('.reftext').count

      verse_doc.css('.passage p').each do |verse_link|
        if verse_link.content.length == 0
          next
        end

        verse_hash = { type: '', content: '' }

        if verse_link.css('.paragraphtitle').count > 0
          verse_hash[:type] = 'passage'
          verse_hash[:content] = verse_link.content
        elsif verse_link.css('span[data-begin]').count > 0
          verse_hash[:type] = 'verse'
          verse_hash[:number] = verse_link.css('span.reftext').first.content.to_i
          verse_hash[:content] = verse_link.css('span[data-begin]').first.content
        end

        chapter_hash[:verses].push(verse_hash)
      end

      book_hash[:chapters].push(chapter_hash)
    end

    json[:books].push(book_hash)

    File.open('TB.json', 'w') do |f|
      f.write(JSON.pretty_generate(json))
    end

    puts 'Done!'
  end
end
