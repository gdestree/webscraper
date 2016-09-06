# Require gems for sending get request:HTTParty, parsing:Nokogiri, debugging:pry, write to csv:csv
require "HTTParty"
require "Nokogiri"
require "Pry"
require "csv"

# Methods for functionality: amount of pages to scrape(for until loop), page parsing, get content from parsed page 
def pages_to_scrape 
	puts "How many pages of WeGotTickets would you like to scrape?"
	gets.chomp.to_i
end

def page_parser(page)
	Nokogiri::HTML(page)
end

def get_content(parsed_page)
	parsed_page.css('.content.block-group.chatterbox-margin')
end

def csv_generator(events)
	column_names = events.first.keys
	
	CSV.generate do |csv|
  	csv << column_names
  	events.each do |event|
    	csv << event.values
  	end
	end
end

def write_to_csv_file(events_csv)
	File.write('ticket_scraper.csv', events_csv)
end

# Driver code
# set variables for amount of pages to scrape
number_of_pages = pages_to_scrape
x = 1

# empty events array to store the events in
events = []

# Until loop to loop through pages and save each event to events. Once the loop has been fulfilled write to a csv file
until x > number_of_pages
	page = HTTParty.get("http://www.wegottickets.com/searchresults/page/#{x}/all#paginate")
	parsed_page = page_parser(page)
	content = get_content(parsed_page)

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

events_csv = csv_generator(events)
write_to_csv_file(events_csv)

puts "Scraping complete - #{events.length} events written to csv."