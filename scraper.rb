require 'rubygems'
require 'mechanize'
require 'csv'
require 'json'
require_relative 'pagescrape.rb'

def scraper
	daycares = []
	agent1 = Mechanize.new
	agent2 = Mechanize.new

	# output = File.new("output2.csv","w")
	# output.print("centerName,permitHolder,address,borough,phone,zipCode,permitNumber,permitExpirationDate,permitStatus,ageRange,maximumCapacity,certifiedToAdministerMedication,siteType")
	# output.print("\n")

	offset = 0

	# do initial pageview
	form_data = {
		linkPK:0,
		pageroffset:0,
		getNewResult:true,
		progTypeValues: '', 
		search:1, 
		facilityName: '', 
		borough: '', 
		permitNo: '', 
		neighborhood: '', 
		zipCode: '' 
	}
	page = agent1.post 'https://a816-healthpsi.nyc.gov/ChildCare/SearchAction2.do'
	form = page.forms.first
	page = form.submit
	agent1.cookie_jar.save_as 'cookies', :session => true, :format => :yaml

	while offset < 2300 do #  < 10 for testing, 2300 at least for real
		puts "Offset: " + offset.to_s
		page = agent1.post 'https://a816-healthpsi.nyc.gov/ChildCare/SearchAction2.do?pager.offset=' + offset.to_s, form_data

		links = page.search('tr.gradeX.odd a')
		file_i = offset
		links.each do |link|
			id = link.to_s()
			id = id.split('redirectHistory(')[1]
			id = id[0,10]
			id = id.scan(/"([^"]*)"/)
			# puts id

			agent2.cookie_jar = agent1.cookie_jar

			idString = 'linkPK=' + id[0][0].to_s
			# puts idString

			page2 = agent2.post 'https://a816-healthpsi.nyc.gov/ChildCare/WDetail.do', idString ,({'Content-Type' => 'application/x-www-form-urlencoded'})
			daycare = pagescrape(page2)	
			filename = file_i.to_s.rjust(2, "0")
			File.open("json/#{ filename }.json","w") do |f|
			  f.write(JSON.pretty_generate(daycare))
			end

			daycares.push(daycare)
			file_i += 1

		end

		offset = offset + 10

	end

	File.open("json/daycares.json", "w") do |f|
		f.write(JSON.pretty_generate(daycares))
	end
	return daycares

end

scraper