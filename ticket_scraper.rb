require "HTTParty"
require "Nokogiri"
require "Pry"
require "csv"

puts "How many pages of WeGotTickets would you like to scrape?"
number_of_pages = gets.chomp.to_i

events= []
x = 1

until x > number_of_pages
	page = HTTParty.get("http://www.wegottickets.com/searchresults/page/#{x}/all#paginate")
	parsed_page = Nokogiri::HTML(page)
	content = parsed_page.css('.content.block-group.chatterbox-margin')

	y = 0
	10.times do
		events.push(
			name: content[y].css('.event_link').text, 
			location: content[y].css('.venue-details > h4')[0].text,
			date_time: content[y].css('.venue-details > h4')[1].text,
			optional_artists: content[y].css('.venue-details > h4')[2].text,
			price: content[y].css('.searchResultsPrice').text,
			event_page: content[y].css('a @href').first.value
		)
		puts "Page: #{x} - Event: #{y+1} has been written"
		y+=1
	end
	x+=1
end

column_names = events.first.keys
events_csv=CSV.generate do |csv|
  csv << column_names
  events.each do |event|
    csv << event.values
  end
end

File.write('ticket_scraper.csv', events_csv)
puts "Scraping complete - #{events.length} events written to csv."